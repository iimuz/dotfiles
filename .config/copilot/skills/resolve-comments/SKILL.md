---
name: resolve-comments
description: Resolve PR review comments when users ask to gather facts, evaluate fixes, verify diffs, and commit approved changes.
user-invocable: true
disable-model-invocation: false
---

# Resolve Comments

## Overview

Resolve pull request review comments through a staged workflow: gather facts, evaluate
what should change, apply approved fixes, verify the result, and report the outcome.

At execution start, generate a `YYYYMMDDHHMMSS` timestamp and derive:

- Intermediate artifacts: `{session_dir}/{timestamp}-resolve-comments/` (referred to as `run_dir`)
- Final output: `{session_dir}/{timestamp}-resolve-comments-summary.md`

`session_dir` resolves to `~/.copilot/session-state/{session_id}/files/`.

## Workflow

### Stage 1: Gather

Extract factual observations from the review comments. Record referenced files, explicit
requests, and comment context. Never include recommendations, prioritization, or opinions.

task(general-purpose, model=gemini-3-pro-preview):

> Read the review comments and optional context. Extract only factual statements.
> Write the result to {run_dir}/gather.md.

- Output: `{run_dir}/gather.md` (read by Stage 2)
- Fault: Abort if the task fails, the file is missing, or the output contains evaluative language.

### Stage 2: Evaluate

Transform the gather artifact into eval-input, then run council deliberation to produce
a fix plan. The coordinator must not build eval-input inline; delegate that transformation
to a sub-agent. Classify ambiguous evaluation results as non-actionable (fail-closed).

task(general-purpose):

> Read {run_dir}/gather.md, strip judgmental or advisory language, and write
> sanitized input to {run_dir}/eval-input.md.

skill(council):

> Evaluate {run_dir}/eval-input.md. Write council output to {run_dir}/council.json.

Parse the council output into a structured fix plan with item IDs and concrete change
actions. Compute actionable_count and set skip_decision (true when no actionable items
exist). Write `{run_dir}/fix-plan.json`.

- Output: `{run_dir}/eval-input.md`, `{run_dir}/council.json`, `{run_dir}/fix-plan.json` (read by Stage 3)
- Fault: Abort if eval-input or council invocation fails.

### Stage 3: Implement

Execute the fix plan when actionable items exist. Skip when skip_decision is true and
write skip status instead.

skill(task-coordinator):

> Implement the changes described in {run_dir}/fix-plan.json.

- Output: `{run_dir}/implement.json` (read by Stage 4)
- Fault: Continue with recorded failure status if task-coordinator cannot complete the plan.

### Stage 4: Verify

Review the implemented changes and record severity counts for the commit gate.

skill(code-review, model=claude-opus-4.6):

> Review unstaged working-tree changes produced by Stage 3.

When Stage 3 was skipped, verify that no unintended unstaged changes exist and mark
verification as passed-with-skip-context.

- Output: `{run_dir}/verify.json` with `{ critical_count, high_count, medium_count, low_count }` (read by Stage 5)
- Fault: Continue with verification-unavailable status if code-review fails.

### Stage 5: Commit

Commit the changes only when the severity gate passes: critical_count == 0 and
high_count == 0. Read verify.json and parse critical_count and high_count strictly.

task(general-purpose, model=gpt-5.4):

> Stage implementation changes with git add. If no staged changes exist, skip with
> commit_skip_reason: no_staged_changes. Otherwise invoke skill(commit-staged).
> Write result to {run_dir}/commit.json.

- Output: `{run_dir}/commit.json` (read by Stage 6)
- Fault: Skip commit when critical_count > 0, high_count > 0, or severity parsing fails.
- Fault: Continue with commit-failed status if commit-staged fails after staging.

### Stage 6: Summarize

Write a final summary covering gather, evaluate, implement, verify, and commit outcomes.
Report skips, degraded paths, unresolved risks, and any commit_skip_reason explicitly.

- Output: `{session_dir}/{timestamp}-resolve-comments-summary.md`
- Fault: Abort if the final summary file cannot be written.

## Session Files

- `{run_dir}/gather.md`
- `{run_dir}/eval-input.md`
- `{run_dir}/council.json`
- `{run_dir}/fix-plan.json`
- `{run_dir}/implement.json`
- `{run_dir}/verify.json`
- `{run_dir}/commit.json`
- `{session_dir}/{timestamp}-resolve-comments-summary.md`

## Output

Final output path: `{session_dir}/{timestamp}-resolve-comments-summary.md`

## Examples

- Happy: review requests a null check and test update, both are actionable, verification
  is clean, commit succeeds.
- Failure: review comments are contradictory, evaluation classifies them as non-actionable,
  implementation and commit are skipped, summary reports the skip reason.
- Failure: implementation succeeds but verification reports one high issue, commit is
  skipped with severity_gate_failed, summary reports the blocked commit.
