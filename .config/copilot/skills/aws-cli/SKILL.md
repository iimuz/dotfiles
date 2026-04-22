---
name: aws-cli
description: >-
  Must be used for any AWS CloudWatch Logs retrieval, search, or debugging via AWS CLI.
user-invocable: true
disable-model-invocation: false
---

# AWS CLI

## Overview

This workflow skill dispatches a single autonomous investigation subagent for CloudWatch Logs.
The main agent never runs AWS CLI commands and never reads raw log files.

At execution start, generate one `YYYYMMDDHHMMSS` timestamp. Resolve `session_dir` to
`~/.copilot/session-state/{session_id}/files/`, derive `{session_dir}/{timestamp}-aws-cli/`
as `run_dir`, and derive `{session_dir}/{timestamp}-aws-cli-summary.md` for the final summary.
Create `run_dir` once, verify it exists immediately after creation, and abort if that
verification fails.

## Input

- `request: string` (required) - User request that defines the investigation goal.
- `profile: string` (required) - AWS profile for subagent retrieval work.
- `region: string` (required) - AWS region for subagent retrieval work.
- `log_groups: string[]` (optional) - Suggested CloudWatch log groups to investigate.
- `time_range: string` (optional) - Suggested time scope for the investigation.

## Output

- `summary_path: string` (required) - Final summary path at
  `{session_dir}/{timestamp}-aws-cli-summary.md`.
- `resolved: boolean` (required) - Whether the investigation reached a satisfactory conclusion.
- `findings: string[]` (required) - Investigation findings from the subagent.
- `artifact_paths: string[]` (required) - Paths saved by the investigation subagent.
- `remaining_unknowns: string[]` (optional) - Outstanding questions when the investigation remains
  unresolved.

## Execution Flow

### Stage 1: Initialize

Create one run timestamp, derive `run_dir`, create it under
`{session_dir}/{timestamp}-aws-cli/`, and verify the directory exists before subagent work
begins. Prepare the final summary path at `{session_dir}/{timestamp}-aws-cli-summary.md`.

- Output: `timestamp`, `run_dir`, `summary_path`.
- Fault: Abort if `run_dir` cannot be created or verified.

### Stage 2: Investigate

Dispatch a single autonomous investigation subagent. The subagent handles its own
retrieval-analysis iteration loop internally (up to 5 cycles). Adapt the prompt template below
with the actual context.

task(general-purpose, model=claude-opus-4.6):

> Read [references/log-retrieval-rules.md](references/log-retrieval-rules.md) for investigation rules,
> boundaries, and output format.
> request={request},
> run_dir={run_dir},
> profile={profile},
> region={region},
> investigation_context={request} with optional hints: log_groups={log_groups},
> time_range={time_range}

- Output: `summary`, `saved_paths`, `resolved`, and `remaining_unknowns`.
- Fault: Retry once on malformed output. Abort on repeat failure.

### Stage 3: Finalize

Write the final summary to `{session_dir}/{timestamp}-aws-cli-summary.md`. Include the
subagent findings, list all artifact paths, and note whether the result is resolved or partial.
When unresolved, the summary must explicitly include remaining unknowns, any failed log groups,
and expired credential findings that limited the investigation.

- Output: Final summary at `{session_dir}/{timestamp}-aws-cli-summary.md`.
- Fault: Abort if the final summary cannot be written, and report the filesystem failure.

## Examples

- Happy: Investigate Lambda timeout errors, subagent iterates autonomously, and
  write a resolved summary with saved artifact paths.
- Failure: Subagent exhausts investigation cycles, preserve accumulated findings, and
  write a partial summary with remaining unknowns.
