---
name: task-coordinator-execute
description: Execute plan tasks via inline single-worker or parallel pipeline dispatch.
user-invocable: false
disable-model-invocation: true
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

// Mirrored from task-coordinator (canonical source)
type Plan = {
  schema_version: string;
  run_id: string;
  goal: string;
  tasks: Task[];
  synthesis_output_file: string;
};

type Task = {
  id: string;
  agent_type: AgentType;
  prompt_file: string;
  output_file: string;
  depends_on: string[];
  description?: string;
  model?: string;
};

type AgentType = "explore" | "task" | "general-purpose" | "code-review";
type WorkerReceipt = {
  status: "WORKER_OK" | "WORKER_FAIL";
  id: string;
  reason?: string;
};
type InlineResult = WorkerReceipt;
```

## Operations

```typespec
op execute_inline(p: Plan) -> InlineResult {
  // Exactly 1 task: spawn worker passing prompt_file path; receive result inline; skip synthesize
  invariant: Execution_Only     => (subagent_prompt_is_advisory_not_actionable) => convert_to_execution_directive;
  invariant: No_Peeking         => (reads_T_n_prompt or reads_T_n_output) => CONTRACT_VIOLATION_NO_PEEKING("abort; restart strict mode");
  invariant: (worker_fails)       => retry_once(p.tasks[0].id);
  invariant: (worker_fails_again) => abort("Worker failed after retry");
}

op execute_pipeline(p: Plan) -> WorkerReceipt[] {
  // 2+ tasks: spawn independent workers in parallel (cap 5-8); batch waves per depends_on
  invariant: Execution_Only     => (subagent_prompt_is_advisory_not_actionable) => convert_to_execution_directive;
  invariant: No_Peeking         => (reads_T_n_prompt or reads_T_n_output) => CONTRACT_VIOLATION_NO_PEEKING("abort; restart strict mode");
  invariant: (worker_fails(receipt))       => retry_once(receipt.id);
  invariant: (worker_fails_again(receipt)) => record(WORKER_FAIL, receipt.id, "continue; preserve completed results");
  invariant: (tasks_length > 8)            => batch_in_waves("respecting depends_on order");
}
```

## Execution

```text
[execute_inline | execute_pipeline]
```

Symbol legend: `|` = XOR branch (gated by `plan.tasks.length`).

## Agent Selection

Match subtasks to the lightest capable agent:

| Requirement                            | Agent type            |
| :------------------------------------- | :-------------------- |
| Code investigation, symbol/file search | `explore`             |
| Build, test, lint, install             | `task`                |
| Multi-step implementation, code edits  | `general-purpose`     |
| Review without modifying code          | `code-review`         |
| Domain-specific work                   | `<custom-agent-name>` |

Model guidance: `claude-opus-4.6` -- nuanced reasoning; `gpt-5.3-codex` -- structured output, tool-heavy workflows;
`gemini-3-pro-preview` -- broad knowledge synthesis. Prefer the same model within a multi-step subtask.
