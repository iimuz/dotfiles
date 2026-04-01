---
name: implement-cycle
description: >-
  Use when executing a plan through iterative Implement, Commit, and Review
  cycles.
user-invocable: true
disable-model-invocation: false
---

# Implement Cycle

## Overview

Orchestrator that runs a 3-stage iterative cycle: Implement -> Commit -> Review. The loop repeats
up to 3 times and stops as soon as review returns no Critical or High issues. The plan is assumed
to exist before invocation. Do not call `ask_user()` between phases. Abort if `{plan_filepath}`
cannot be read or if any stage skill fails.

At execution start, obtain `{session_id}` from the CLI environment and resolve `{session_dir}` as
`~/.copilot/session-state/{session_id}/files/`, then generate `{timestamp}` in
`YYYYMMDDHHMMSS` format. Record the current HEAD as `{base_sha}` before any changes.

- `{run_dir}` = `{session_dir}/{timestamp}-implement-cycle/`
- `{final_output}` = `{session_dir}/{timestamp}-implement-cycle-summary.md`
- `{base_sha}` = HEAD at workflow start (used as the review comparison base)

## Input

- `{task}` - Description of what to implement.
- `{plan_filepath}` - Path to the plan file (default: `docs/planning.md` or the session plan file).
  The plan must already exist with populated Steps.

## Execution Flow

### Stage 1: Implement

Read `{plan_filepath}` and implement the pending steps.

On iteration 1, derive scope from the plan's pending steps. On iteration 2+, scope is narrowed to
only Critical and High issues from the prior review that still advance the plan goal. Exclude
unrelated or pre-existing findings.

After implementation, update `{plan_filepath}` Steps: check off (`- [x]`) any steps completed in
this iteration.

- Output: Code changes in the working tree and updated `{plan_filepath}`.
- Fault: Abort and report the error if `{plan_filepath}` cannot be read.

### Stage 2: Commit

Stage only implementation-related changes for iteration `{n}` and commit.

Invoke `skill(git-commit)` to create a Conventional Commit.

- Output: `commit` metadata for Stage 3 and Summary.
- Fault: Abort and report the context if nothing relevant is staged or if `git-commit` fails.

### Stage 3: Review

Review the cumulative changes against the plan intent. Carry forward only Critical and High
issues, tagging each carried issue with the iteration number that produced it. Medium and Low
issues belong in the final report but must not trigger another loop.

Before the first review, write a one-paragraph design summary of the plan intent to
`{run_dir}/plan-summary.md` for the reviewer to use as context.

On iteration 1, invoke `skill(code-review)` with `target=HEAD` and
`design_info_filepath={run_dir}/plan-summary.md`.

On iteration 2+, invoke `skill(code-review)` with `target={base_sha}` and
`design_info_filepath={run_dir}/plan-summary.md` so the reviewer sees all changes from the
workflow start. Write the previous verdict to `{run_dir}/prior-verdict-{n}.md` and reference it
in the design context so the reviewer can verify that prior Critical and High issues are resolved.

- Output: `verdict` for the loop controller and Summary.
- Fault: Abort and report the error if `code-review` fails or the verdict cannot be interpreted.

### Summary

After the first clean review or after the third iteration, write the final report in Japanese
directly to `{final_output}`. The report must include: the plan path, iteration history, commits,
fixed issues, remaining issues, and recommendations.

- Output: `{final_output}` for the final user-facing response.
- Fault: Abort and report the error if the final report cannot be written.

## Session Files

- `{plan_filepath}` (input, updated during execution)
- `{run_dir}/plan-summary.md` from Stage 3 (first iteration)
- `{run_dir}/prior-verdict-{n}.md` from Stage 3 (iteration 2+)
- `{final_output}` from Summary
