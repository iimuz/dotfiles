---
name: task-coordinator-plan
description: Decompose a request into a validated execution plan.
user-invocable: false
disable-model-invocation: false
---

# Task Coordinator: Plan

## Overview

Transform the request into a validated execution plan. Read `references/planner-protocol.md` for
prompt strategy, then read `references/plan-schema.md` for validation rules. Decompose the request
into tasks, validate the plan against the schema, and persist `plan.json`. When validation fails,
write `plan-errors.json` and abort.

## Schema

```typescript
type PlanTask = {
  id: string;
  agent_type: "explore" | "task" | "general-purpose" | "code-review";
  prompt_file: string;
  output_file: string;
  model?: "claude-opus-4.6" | "gpt-5.3-codex" | "gemini-3-pro-preview";
  depends_on: string[];
};

type Plan = {
  schema_version: string;
  run_id: string;
  goal: string;
  tasks: PlanTask[];
  synthesis_output_file: string;
};
```

## Constraints

- Retry once and continue when planner output is missing.
- Abort after writing `plan-errors.json` when plan validation fails.
- Keep all `prompt_file` and `output_file` paths under `run_dir`.
- Copy the input `run_id` into the plan output `run_id` field without modification.
- Follow `references/planner-protocol.md` for planner prompt templates, receipt format, and validation rules.
- Follow `references/plan-schema.md` for schema definitions, validation rules, field references, and mode logic.

## Input

| Field     | Type     | Required | Description                                             |
| --------- | -------- | -------- | ------------------------------------------------------- |
| `request` | `string` | yes      | User request to decompose                               |
| `run_id`  | `string` | yes      | Run identifier provided by orchestrator                 |
| `run_dir` | `string` | yes      | Run directory path provided by orchestrator for scoping |

## Output

- plan: validated plan ready for execution
- validation errors: persisted to `plan-errors.json` when validation fails

## Examples

### Happy Path

- Input: { request: "Build auth module", run_dir: "/tmp/run-1" }
- Output: plan.json written to /tmp/run-1/plan.json with 3 tasks

### Failure Path

- `validate_plan` detects cyclic dependency.
- Abort after writing `plan-errors.json`.
