---
name: task-coordinator-plan
description: Decompose a request into a validated execution plan via Planner subagent.
user-invocable: false
disable-model-invocation: true
---

# Task Coordinator: Plan

## Role

Planning phase of the task-coordinator pipeline. Spawns a Planner subagent to decompose
a user request into an executable plan, then validates the resulting `plan.json`.

## Interface

```typescript
/**
 * @skill task-coordinator-plan
 * @input  { request: string; session_id: string; run_id: string; run_dir: string }
 * @output { plan: Plan }
 */

// Types: Plan, Task, AgentType

type AgentType = "explore" | "task" | "general-purpose" | "code-review";
type Task = {
  id: string;
  agent_type: AgentType;
  prompt_file: string;
  output_file: string;
  depends_on: string[];
  description?: string;
  model?: string;
};
type Plan = {
  schema_version: string;
  run_id: string;
  goal: string;
  tasks: Task[];
  synthesis_output_file: string;
};
type WorkerReceipt = {
  status: "WORKER_OK" | "WORKER_FAIL";
  id: string;
  reason?: string;
};
type SynthesisReceipt = {
  status: "SYNTHESIS_OK" | "SYNTHESIS_FAIL";
  output_file: string;
  summary: string;
  reason?: string;
};

/**
 * @invariants
 * - invariant: (direct_implementation_attempt) => abort("Delegate to Planner first");
 * - invariant: (coordinator_investigates_before_plan) => abort("Pass request verbatim to Planner; coordinator must not invoke investigation tools before plan op");
 */
```

> **Severity model**
>
> - `abort(reason)` — halt execution immediately; do not produce partial output.
> - `warn(reason)` — log the issue and continue in degraded mode.

## Operations

```typespec
op plan(request: string, session_id: string, run_id: string, run_dir: string) -> Plan {
  // Set planner_protocol_file = {skill_base_dir}/references/planner-protocol.md
  // Set plan_schema_file = {skill_base_dir}/references/plan-schema.md
  // Spawn Planner: task(prompt="Read {planner_protocol_file} and follow instructions.\n\n## Input Context\n- request: {request}\n- session_id: {session_id}\n- run_id: {run_id}\n- run_dir: {run_dir}\n- plan_schema_file: {plan_schema_file}")
  invariant: (direct_implementation_attempt) => abort("Delegate to Planner first");
  invariant: (coordinator_investigates_before_plan) => abort("Pass request verbatim to Planner; coordinator must not invoke investigation tools before plan op");
  invariant: (planner_response_lines > 5) => warn("Response has extra lines; verify plan.json on disk");
  invariant: (plan_json_missing) => retry_once("refined prompt");
  invariant: (plan_json_missing_on_retry) => abort("Planner failed; report error receipt only");
}

op validate_plan(p: Plan, run_dir: string) -> Plan {
  invariant: (json_parse_error) => abort("plan.json: parse failure");
  invariant: (missing_required_field) => abort("plan.json: missing field");
  invariant: (duplicate_task_id) => abort("plan.json: duplicate task ID");
  invariant: (circular_dependency) => abort("plan.json: dependency cycle");
  invariant: (path_escapes_run_dir) => abort("plan.json: path traversal rejected");
  invariant: (prompt_file_absent) => abort("plan.json: prompt file not found");
  invariant: (tasks_length > 15) => abort("plan.json: exceeds 15-task limit");
}
```

## Execution

```text
plan -> validate_plan
```

Reference files are subagent-only; pass paths to the Planner subagent — do not load into caller context:

- `planner_protocol_file` = `{skill_base_dir}/references/planner-protocol.md`
- `plan_schema_file` = `{skill_base_dir}/references/plan-schema.md`

| dependent     | prerequisite | description                                    |
| ------------- | ------------ | ---------------------------------------------- |
| _(col key)_   | _(col key)_  | _(dependent requires prerequisite first)_      |
| validate_plan | plan         | validate_plan consumes Plan written by plan op |

## Input

| Field        | Type     | Required | Description                               |
| ------------ | -------- | -------- | ----------------------------------------- |
| `request`    | `string` | yes      | User's task request (passed verbatim)     |
| `session_id` | `string` | yes      | Current session identifier                |
| `run_id`     | `string` | yes      | Run identifier (`tc-{YYYYMMDD}-{HHMMSS}`) |
| `run_dir`    | `string` | yes      | Run directory path for plan.json output   |

## Output

| Field  | Type   | Description                             |
| ------ | ------ | --------------------------------------- |
| `plan` | `Plan` | Validated execution plan as `plan.json` |
