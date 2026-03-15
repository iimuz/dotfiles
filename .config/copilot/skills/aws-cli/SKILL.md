---
name: aws-cli
description: >-
  AWS CLI CloudWatch Logs investigation coordinator. Use when the user asks to
  retrieve, analyze, or investigate CloudWatch Logs, debug Lambda or ECS
  issues using log data, or correlate events across AWS services.
user-invocable: true
disable-model-invocation: false
---

# AWS CLI

## Overview

This workflow skill coordinates iterative CloudWatch Logs investigation through task subagents.
The main agent never runs AWS CLI commands and never reads raw log files.

Subagents are autonomous investigators. The orchestrator provides the problem, the infrastructure
context, and the findings accumulated so far. Each investigation subagent independently decides
which log groups to query, what time ranges to search, and what analysis to perform.

At execution start, generate one `YYYYMMDDHHMMSS` timestamp. Resolve `session_dir` to
`~/.copilot/session-state/{session_id}/files/`, derive `{session_dir}/{timestamp}-aws-cli/`
as `run_dir`, and derive `{session_dir}/{timestamp}-aws-cli-summary.md` for the final summary.
Create `run_dir` once, verify it exists immediately after creation, and abort if that
verification fails.

The investigation loop runs for at most 5 iterations. After each unresolved result, re-dispatch
Stage 2 with the accumulated prior summaries so the next investigation subagent can pivot
autonomously. If the loop still ends unresolved, write a partial final summary with findings,
artifact paths, and remaining unknowns.

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
- `findings: string[]` (required) - Iteration summaries accumulated through the loop.
- `artifact_paths: string[]` (required) - Paths saved by investigation subagents.
- `remaining_unknowns: string[]` (optional) - Outstanding questions when the investigation remains
  unresolved.

## Execution Flow

### Stage 1: Initialize

Create one run timestamp, derive `run_dir`, create it under
`{session_dir}/{timestamp}-aws-cli/`, and verify the directory exists before any subagent work
begins. Initialize empty arrays for findings, artifact paths, and prior summaries, prepare the
final summary path at `{session_dir}/{timestamp}-aws-cli-summary.md`, and set loop state for up
to 5 iterations.

- Output: `timestamp`, `run_dir`, `summary_path`, and the initial loop state.
- Fault: Abort if `run_dir` cannot be created or verified.

### Stage 2: Investigate

Dispatch a task subagent for the current iteration. Adapt the prompt template below with the
current iteration context, including optional hints and the summaries accumulated so far.

task(general-purpose, model=claude-opus-4.6):

> Here is the user problem, the infrastructure context including `profile`, `region`, and
> `run_dir`, any optional hints such as `log_groups` and `time_range`, and the prior findings
> from earlier iterations. Invoke `aws-cli-log-retrieval` via `skill()` for retrieval best
> practices, investigate autonomously, and return only `summary`, `saved_paths`, and `resolved`.
> Never include raw log content.

- Output: `summary`, `saved_paths`, `resolved`, and any artifacts written in `run_dir`.
- Fault: If the subagent returns malformed structure or raw log content, retry once with a
  refined prompt and abort on repeat failure.

### Stage 3: Evaluate

Review the Stage 2 result, append valid summaries and saved paths to the running findings, and
decide whether the investigation is resolved or unresolved. If it is unresolved and iterations
remain, continue the loop by re-dispatching Stage 2 with the accumulated prior summaries and
artifact paths so the next subagent can pivot from earlier findings.

- Output: Updated findings, artifact paths, prior summaries, and the next loop decision.
- Fault: Treat empty or malformed investigation results as unresolved and continue only if the
  iteration limit has not been reached.

### Stage 4: Finalize

End the loop when `resolved` becomes true or when 5 iterations have been used. Write the final
summary to `{session_dir}/{timestamp}-aws-cli-summary.md`, include the findings gathered across
iterations, list all artifact paths, and note whether the result is resolved or partial. When the
loop ends unresolved, the summary must explicitly include remaining unknowns, any failed log
groups, and expired credential findings that limited the investigation.

- Output: Final summary at `{session_dir}/{timestamp}-aws-cli-summary.md`.
- Fault: Abort if the final summary cannot be written, and report the filesystem failure.

## Examples

- Happy: Investigate Lambda timeout errors, loop through autonomous subagent iterations, and
  write a resolved summary with saved artifact paths.
- Failure: Exhaust 5 autonomous investigation iterations, preserve accumulated findings, and
  write a partial summary with remaining unknowns.
