---
name: daily-summary
description: >-
  Use when summarizing daily work activity into a report by analyzing
  Copilot session logs and GitHub activity (issues, PRs) for a specified date.
user-invocable: true
disable-model-invocation: false
---

# Daily Summary

## Overview

Generate a qualitative daily work summary from Copilot session logs and
GitHub activity (issues, PRs). Scripts identify sessions and GitHub
activities for the target date, sub-agents analyze each source in parallel,
then the results are consolidated into a structured daily report that merges
overlapping items from both sources.

Execution order: determine date -> identify sources (parallel) -> parallel
sub-agent analysis -> consolidate and merge -> save and present.

## Input

- `date: string` (optional): Target date in YYYY-MM-DD format. Defaults to today.
- `end_date: string` (optional): End date for a range in YYYY-MM-DD format.
  Defaults to `date` when omitted.

## Output

- Per-session summaries saved to `{run_dir}/session-{uuid}.md`.
- Per-activity summaries saved to `{run_dir}/activity-{type}-{owner}-{repo}-{number}.md`.
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

### Stage 2: Identify Sources

Run both scripts in parallel to collect Copilot sessions and GitHub activities.

#### 2a: Identify Sessions

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

#### 2b: Identify GitHub Activities

Run [`scripts/extract-activities.sh`](scripts/extract-activities.sh) with
`--date YYYY-MM-DD`. For date ranges, add `--end-date YYYY-MM-DD`.

The script queries GitHub via `gh search` to find issues and PRs the user
was involved with during the target period. Three queries are combined:
issues involved, PRs involved, and PRs reviewed. Results are deduplicated.

Output is a JSON array of activity metadata:

- `type`: `issue` or `pr`
- `number`: Issue or PR number
- `owner`: Repository owner
- `repo`: Repository name
- `title`: Issue or PR title
- `url`: GitHub URL
- `state`: Current state

#### Handling Empty Results

If both outputs are empty arrays, inform the user that no sessions or
activities were found for the specified date and stop.

If only one source has results, proceed with that source alone. Both
sources are not required.

### Stage 3: Parallel Analysis

Create a run directory for intermediate outputs:
`~/.copilot/session-state/{session_id}/files/{YYYYMMDDHHMMSS}-daily-summary/`

Launch all sub-agents in parallel across both source types.

#### 3a: Session Sub-Agents

For each session from Stage 2a, launch a sub-agent (`task()` with
`agent_type: "daily-summary-session"`) to analyze the session in detail.

Pass each sub-agent:

- `session_path`: from the Stage 2a output
- `output_filepath`: `{run_dir}/session-{session_id_being_analyzed}.md`

The agent definition at `.config/copilot/agents/daily-summary-session.md`
specifies the model, tools, and analysis procedure. Each sub-agent writes
its summary as a markdown file to the specified output path.

#### 3b: Activity Sub-Agents

For each activity from Stage 2b, launch a sub-agent (`task()` with
`agent_type: "daily-summary-activity"`) to analyze the issue or PR in full.

Retrieve the authenticated GitHub username before launching activity
sub-agents:

```bash
gh api user --jq .login
```

Pass each sub-agent:

- `type`: `issue` or `pr`
- `owner`: Repository owner
- `repo`: Repository name
- `number`: Issue or PR number
- `date`: Start date of the target period
- `end_date`: End date of the target period
- `github_user`: Authenticated GitHub username
- `output_filepath`: `{run_dir}/activity-{type}-{owner}-{repo}-{number}.md`

The agent definition at `.config/copilot/agents/daily-summary-activity.md`
specifies the model, tools, and analysis procedure. Each sub-agent fetches
the full issue/PR history, understands the complete context, and produces a
summary scoped to the user's activity within the target period.

#### Failure Handling

If a sub-agent fails, note the failure and continue with other items.
Do not retry failed sub-agents.

### Stage 4: Consolidate

Read all summary files from the run directory:

- Session summaries: `{run_dir}/session-*.md`
- Activity summaries: `{run_dir}/activity-*.md`

Generate a consolidated markdown summary following the format defined in
[`references/output-format.md`](references/output-format.md).

Key synthesis tasks:

- Group completed items by repository, deduplicating same-task entries.
- Merge overlapping Copilot sessions and GitHub activities that refer to the
  same work. Indicators of overlap include: same repository and branch name,
  PR or issue number referenced in session events, similar task descriptions.
  When merging, combine the context from both sources to write a richer
  description than either source alone provides.
- When the same logical task spans multiple repositories, group them
  into a single collective entry.
- Identify significant decisions across all sessions and activities.
- List open items with meaningful activity in the period as in-progress items.
- Exclude failed or abandoned sessions from completed items (mention
  them separately if relevant).
- Omit sessions and activities that produced no meaningful outcomes.

### Stage 5: Save and Present

Save the generated markdown to the run directory:
`{run_dir}/{date}-daily-summary.md`

Present the full summary content to the user. If the user requests saving
to an additional location, copy or write the file to the specified path.

## Examples

- Happy: user asks for today's summary, script finds 8 sessions across
  3 repositories and 5 GitHub activities (3 PRs, 2 issues), 13 parallel
  sub-agents produce summaries, 2 sessions and PRs overlap and are merged,
  the consolidated report groups work by repository and lists 7 completed
  items with 2 in-progress items and 1 decision.
- Session only: no GitHub activities found (gh not authenticated or no
  activity), proceeds with Copilot sessions alone. Behaves like the
  original workflow.
- Activity only: no Copilot sessions found but GitHub activities exist,
  proceeds with activities alone.
- Empty: both sources return empty arrays, the user is informed that no
  sessions or activities were found.
- Partial failure: 1 of 13 sub-agents fails, the remaining 12 summaries
  are consolidated successfully with a note about the failed item.
