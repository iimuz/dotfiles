---
name: task-coordinator-plan
description: Decompose a request into a validated execution plan.
user-invocable: false
disable-model-invocation: false
---

# Task Coordinator: Plan

## Overview

Transform the request into a validated execution plan. Read `references/planner-protocol.md`
for prompt strategy and `references/plan-schema.md` for validation rules. Decompose the request
into executable tasks, validate the plan against the schema, and persist `plan.json` only after
validation succeeds. Keep every generated `prompt_file` and `output_file` scoped under `run_dir`
and reject any plan that escapes that directory. Copy the input `run_id` into the output plan
`run_id` field without modification. If planner output is missing, retry once and continue only
if a complete plan is recovered. If validation fails, write `plan-errors.json` and abort.

## Input

- `request: string` - User request to decompose into a validated execution plan.
- `run_id: string` - Run identifier provided by the orchestrator and copied into the plan output.
- `run_dir: string` - Run-scoped directory that must contain every generated prompt and output path.

## Output

- `plan: json file` - Validated `plan.json` ready for execution when planning succeeds.
- `validation_errors: json file` - `plan-errors.json` written when schema validation fails.

## Examples

- Happy: request "Build auth module" produces a validated `plan.json` under the run directory
  with all task files scoped inside that directory.
- Failure: schema validation detects a cyclic dependency, writes `plan-errors.json`, and aborts
  without emitting `plan.json`.
