---
name: structured-workflow
description: >
  Orchestrate Plan, Implement, Review, and Commit phases in an automated
  iterative loop. This skill should be used when coordinating
  implementation-plan, code-review, and commit-staged skills without
  manual confirmation between phases.
user-invocable: true
disable-model-invocation: false
---

# Structured Workflow

## Overview

Orchestrator that runs a fixed 5-phase cycle: Plan -> Implement -> Commit -> Review -> Summary.
Stage 1 runs once, Stages 2 through 4 can repeat up to 3 times, and the loop stops as soon as
review returns no Critical or High issues. Call orchestrator skills through `skill()` directly,
use `task()` only for non-orchestrator work, do not call `ask_user()` between phases, and abort
if `{task}` is missing or if any stage skill fails. The main agent may read only `plan_filepath`,
`{run_dir}/plan-summary.md`, `{run_dir}/sw-implement-request-{n}.md`, and `{final_output}`.
Delegate all other artifact inspection to invoked skills or sub-agents and suppress intermediate
user-facing output until the final summary or an error recovery path.

At execution start, obtain `{session_id}` from the CLI environment and resolve `{session_dir}` as
`~/.copilot/session-state/{session_id}/files/`, then generate `{timestamp}` in
`YYYYMMDDHHMMSS` format.

- `{run_dir}` = `{session_dir}/{timestamp}-structured-workflow/`
- `{final_output}` = `{session_dir}/{timestamp}-structured-workflow-summary.md`

## Execution Flow

### Stage 1: Plan

Generate the implementation plan for `{task}`, then produce a one-paragraph design summary that
later review can treat as the plan intent. This stage runs once before the iteration loop begins.

skill(implementation-plan):

> Invoke `implementation-plan` with `{ session_id, user_request: {task} }` and return
> `plan_filepath`.

task(explore, model=gemini-3-pro-preview):

> Read `{plan_filepath}` and write a one-paragraph summary to `{run_dir}/plan-summary.md`.

- Output: `plan_filepath` and `{run_dir}/plan-summary.md` for Stage 2, Stage 4, and Stage 5.
- Fault: Abort and report the error if `implementation-plan` fails or the summary file is missing.

### Stage 2: Implement

Prepare bounded implementation scope for iteration `{n}` and execute it. Iteration 1 derives scope
from the plan file. Later iterations derive scope only from carried Critical and High issues that
still belong to the plan goal. After the helper returns, the main agent reads
`{run_dir}/sw-implement-request-{n}.md` and passes that request to the execution coordinator.

task(general-purpose, model=claude-opus-4.6):

> Invoke `structured-workflow-implement` with
> `{ session_id, run_dir, plan_filepath, iteration: {n}, prior_issues }` and return
> `{run_dir}/sw-implement-request-{n}.md`.

skill(task-coordinator):

> Read `{run_dir}/sw-implement-request-{n}.md` and implement the requested work.

- Output: `{run_dir}/sw-implement-request-{n}.md` for the main agent to read in this stage.
- Fault: Abort and report the error if the helper task fails, the request file cannot be read, or
  `task-coordinator` fails.

### Stage 3: Commit

Stage only implementation-related changes for iteration `{n}` and create a commit for the reviewed
state. Never include unrelated working-tree changes in this stage.

task(general-purpose, model=gpt-5.4):

> Run `git status`, stage only implementation-related files for iteration `{n}` with `git add`,
> and report whether anything relevant was staged.

skill(commit-staged):

> Create a Conventional Commit from the current staged state.

- Output: `commit` metadata for Stage 4 and Stage 5.
- Fault: Abort and report the context if nothing relevant is staged or if `commit-staged` fails.

### Stage 4: Review

Review the newly committed state against the plan summary. Carry forward only Critical and High
issues, tagging each carried issue with the iteration number that produced it. Medium and Low
issues belong in the final report but must not trigger another loop.

skill(code-review):

> Review `HEAD` with `design_info_filepath={run_dir}/plan-summary.md` and return a verdict with
> Critical, High, Medium, and Low issues.

- Output: `verdict` for the loop controller and Stage 5.
- Fault: Abort and report the error if `code-review` fails or the verdict cannot be interpreted.

### Stage 5: Summary

After the first clean review or after the third review, compile the final report in Japanese. The
report must include the plan path, iteration history, commits, fixed issues, remaining issues, and
recommendations, and it is the only final artifact the main agent may read before responding.

task(explore, model=claude-opus-4.6):

> Read `plan_filepath` and the collected iteration data, then write a Japanese final report to
> `{final_output}` with plan, fixed issues, unfixed issues, history, and recommendations.

- Output: `{final_output}` for the main agent and the final user-facing response.
- Fault: Abort and report the error if the final report cannot be written.

## Session Files

- `plan_filepath` from `implementation-plan`
- `{run_dir}/plan-summary.md` from Stage 1
- `{run_dir}/sw-implement-request-{n}.md` from Stage 2
- `{final_output}` from Stage 5

## Output

Final output path: `{final_output}`.

## Examples

- Happy: `task: "Add OAuth login"` writes `plan_filepath`, completes one iteration, finds no
  Critical or High issues, and writes `{final_output}`.
- Failure: iteration 2 writes `{run_dir}/sw-implement-request-2.md`, but nothing relevant can be
  staged, so the workflow aborts with commit-phase context.
