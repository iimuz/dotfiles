---
name: task-coordinator-execute
description: Execute plan tasks via inline single-worker or parallel pipeline dispatch.
user-invocable: false
disable-model-invocation: false
---

# Task Coordinator: Execute

## Role

Execution phase of the task-coordinator pipeline. Dispatches plan tasks to worker
subagents, either as a single inline execution or as batched parallel pipeline waves.

## Interface

```typescript
/**
 * @skill task-coordinator-execute
 * @input  { plan: Plan }
 * @output { result: InlineResult | WorkerReceipt[] }
 */

// Types: Plan, Task, AgentType, WorkerReceipt, InlineResult

type InlineResult = {
  task_id: string;
  output: string;
};

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
 * - invariant: (subagent_prompt_is_advisory_not_actionable) => warn("rewrite prompt as actionable directive before executing");
 * - invariant: (reads_T_n_prompt or reads_T_n_output) => abort("No peeking: restart strict mode");
 */
```

> **Severity model**
>
> - `abort(reason)` — halt execution immediately; do not produce partial output.
> - `warn(reason)` — log the issue and continue in degraded mode.

## Operations

```typespec
op execute_inline(p: Plan) -> InlineResult {
  // Exactly 1 task: spawn worker passing prompt_file path; receive result inline; skip synthesize
  invariant: (subagent_prompt_is_advisory_not_actionable) => warn("rewrite prompt as actionable directive before executing");
  invariant: (reads_T_n_prompt or reads_T_n_output) => abort("No peeking: restart strict mode");
  invariant: (worker_fails) => warn("retry task once before aborting");
  invariant: (worker_fails_again) => abort("Worker failed after retry");
}

op execute_pipeline(p: Plan) -> WorkerReceipt[] {
  // 2+ tasks: spawn independent workers in parallel (cap 5-8); batch waves per depends_on
  invariant: (subagent_prompt_is_advisory_not_actionable) => warn("rewrite prompt as actionable directive before executing");
  invariant: (reads_T_n_prompt or reads_T_n_output) => abort("No peeking: restart strict mode");
  invariant: (worker_fails(receipt)) => warn("retry receipt once on first failure");
  invariant: (worker_fails_again(receipt)) => warn("Worker failed after retry; continue preserving completed results");
  invariant: (tasks_length > 8) => warn("batch tasks in waves respecting depends_on order");
}
```

## Execution

```text
[execute_inline | execute_pipeline]
```

Symbol legend: `|` = XOR branch (gated by `plan.tasks.length`).

| dependent        | prerequisite | description                                               |
| ---------------- | ------------ | --------------------------------------------------------- |
| _(col key)_      | _(col key)_  | _(dependent requires prerequisite first)_                 |
| execute_inline   | plan:Plan    | inline path requires pre-validated Plan from plan skill   |
| execute_pipeline | plan:Plan    | pipeline path requires pre-validated Plan from plan skill |

### Agent Selection

Match subtasks to the lightest capable agent:

| Requirement                            | Agent type            |
| :------------------------------------- | :-------------------- |
| Code investigation, symbol/file search | `explore`             |
| Build, test, lint, install             | `task`                |
| Multi-step implementation, code edits  | `general-purpose`     |
| Review without modifying code          | `code-review`         |
| Domain-specific work                   | `<custom-agent-name>` |

Model guidance: `claude-opus-4.6` — nuanced reasoning; `gpt-5.3-codex` — structured output,
tool-heavy workflows; `gemini-3-pro-preview` — broad knowledge synthesis. Prefer the same
model within a multi-step subtask.

## Input

| Field  | Type   | Required | Description              |
| ------ | ------ | -------- | ------------------------ |
| `plan` | `Plan` | yes      | Validated execution plan |

## Output

| Field    | Type                              | Description                                         |
| -------- | --------------------------------- | --------------------------------------------------- |
| `result` | `InlineResult \| WorkerReceipt[]` | Inline receipt (1 task) or receipt array (2+ tasks) |
