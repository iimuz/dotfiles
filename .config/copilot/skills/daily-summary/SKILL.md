---
name: daily-summary
description: >-
  Use when summarizing daily Copilot session activity into a work report
  by analyzing session logs for a specified date.
user-invocable: true
disable-model-invocation: false
---

# Daily Summary

## Overview

Generate a qualitative daily work summary from Copilot session logs. A script
identifies sessions for the target date, sub-agents read each session in full
and produce per-session summaries, then the results are consolidated into a
structured daily report.

Execution order: determine date -> identify sessions -> parallel sub-agent
analysis -> consolidate -> save and present.

## Input

- `date: string` (optional): Target date in YYYY-MM-DD format. Defaults to today.
- `end_date: string` (optional): End date for a range in YYYY-MM-DD format.
  Defaults to `date` when omitted.

## Output

- Per-session summaries saved to `{run_dir}/session-{uuid}.md`.
- Consolidated report saved to `{run_dir}/{date}-daily-summary.md`.
- The summary content is also presented directly to the user.
- If the user requests saving to another location, copy the file accordingly.
- Run directory: `~/.copilot/session-state/{session_id}/files/{YYYYMMDDHHMMSS}-daily-summary/`.

## Operations

### Stage 1: Determine Target Date

Resolve the target date from user input. If no date is specified, use today
in YYYY-MM-DD format (derive from the current datetime provided in the
conversation context). If the user specifies a date range, set both `date`
and `end_date`.

### Stage 2: Identify Sessions

Run [`scripts/extract-sessions.sh`](scripts/extract-sessions.sh) with
`--date YYYY-MM-DD`. For date ranges, add `--end-date YYYY-MM-DD`.

The script scans `~/.copilot/session-state/` for sessions created within
the target date range. Empty sessions (no summary and small events file) are
excluded by default. Add `--include-empty` to include them for debugging.

Output is a JSON array of session metadata:

- `session_id`: UUID
- `session_path`: Absolute path to the session directory
- `created_at`: ISO 8601 timestamp
- `summary`: Session summary from workspace.yaml
- `cwd`: Working directory (repository path)

If the output is an empty array, inform the user that no sessions were found
for the specified date and stop.

### Stage 3: Parallel Session Analysis

Create a run directory for intermediate outputs:
`~/.copilot/session-state/{session_id}/files/{YYYYMMDDHHMMSS}-daily-summary/`

For each session from Stage 2, launch a sub-agent (`task()` with
`agent_type: "daily-summary-session"`) to analyze the session in detail.
Launch all sub-agents in parallel.

Pass each sub-agent:

- `session_path`: from the Stage 2 output
- `output_filepath`: `{run_dir}/session-{session_id_being_analyzed}.md`

The agent definition at `.config/copilot/agents/daily-summary-session.md`
specifies the model, tools, and analysis procedure. Each sub-agent writes
its summary as a markdown file to the specified output path.

If a sub-agent fails, note the failure and continue with other sessions.
Do not retry failed sub-agents.

### Stage 4: Consolidate

Read all session summary files from the run directory (`{run_dir}/session-*.md`).
Generate a consolidated markdown summary following the format defined in
[`references/output-format.md`](references/output-format.md).

Key synthesis tasks:

- Group completed items by repository, deduplicating same-task sessions.
- When the same logical task spans multiple repositories, group them
  into a single collective entry.
- Identify significant decisions across all sessions.
- Exclude failed or abandoned sessions from completed items (mention
  them separately if relevant).
- Omit sessions that produced no meaningful outcomes.

### Stage 5: Save and Present

Save the generated markdown to the run directory:
`{run_dir}/{date}-daily-summary.md`

Present the full summary content to the user. If the user requests saving
to an additional location, copy or write the file to the specified path.

## Examples

- Happy: user asks for today's summary, script finds 8 sessions across
  3 repositories, 8 parallel sub-agents produce session summaries, the
  consolidated report groups work by repository and lists 5 completed
  items with 2 decisions.
- Empty: user asks for a date with no sessions, the script returns an
  empty array, and the user is informed that no sessions were found.
- Partial failure: 1 of 8 sub-agents fails to read a corrupted
  events.jsonl, the remaining 7 summaries are consolidated successfully
  with a note about the failed session.
