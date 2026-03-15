---
name: structured-workflow-implement
description: Prepare implementation request from plan scope.
user-invocable: false
disable-model-invocation: false
---

# Structured Workflow Implement

## Overview

Prepare a bounded natural-language implementation request for the current iteration. Execution
order: determine_scope -> write_checkpoint -> write_request -> write_checkpoint. On iteration 1,
read `plan_filepath` and extract the work required by the plan. On later iterations, use only
Critical and High `prior_issues` that still advance the plan goal and exclude unrelated or
pre-existing findings. If `{run_dir}/sw-implement-request-{n}.md` and the matching complete
checkpoint already exist for the same iteration, return the existing paths without regenerating
them. Abort if `plan_filepath` cannot be read or if any required checkpoint or request write
fails.

## Input

- `plan_filepath: string` - Absolute path to the plan file.
- `iteration: number` - Current iteration number.
- `prior_issues: array` - Previous review issues with severity and change context.
- `run_dir: string` - Absolute path to the run directory.

## Output

- `request_filepath: string` - Path to `{run_dir}/sw-implement-request-{n}.md`.
- `complete_checkpoint_filepath: string` - Path to the matching complete checkpoint.

## Examples

- Happy: iteration 1 reads `/tmp/plan.md`, writes `/tmp/run/sw-implement-request-1.md`, and
  returns both output paths.
- Failure: iteration 2 filters out Medium, Low, and unrelated findings, then aborts because the
  request file cannot be written.
