---
name: task-coordinator-present
description: Present execution results and manage run dashboard.
user-invocable: false
disable-model-invocation: false
---

# Task Coordinator: Present

## Role

Presentation phase of the task-coordinator pipeline. Displays the final result to
the user and maintains the run dashboard.

## Interface

```typescript
/**
 * @skill task-coordinator-present
 * @input  { result: InlineResult | SynthesisReceipt }
 * @output void
 */

// Types: WorkerReceipt, InlineResult, SynthesisReceipt

type InlineResult = {
  task_id: string;
  output: string;
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
 * - invariant: (enumerates_retained_run_files and !explicit_user_request) => abort("Do not enumerate retained run files without user request");
 */
```

> **Severity model**
>
> - `abort(reason)` — halt execution immediately; do not produce partial output.
> - `warn(reason)` — log the issue and continue in degraded mode.

## Operations

```typespec
op present(result: InlineResult | SynthesisReceipt) -> void {
  // Show inline result or receipt summary to user; write dashboard.md
  invariant: (dashboard_missing) => create(dashboard_path, "Pending/Questions/Completed structure");
  invariant: (dashboard_exists) => update(dashboard_path);
  invariant: (run_dirs_count > 5) => prune_oldest("after successful synthesis; retain last 5 runs");
  invariant: (enumerates_retained_run_files and !explicit_user_request) => abort("Do not enumerate retained run files without user request");
}
```

## Execution

```text
present
```

| dependent   | prerequisite                          | description                                                    |
| ----------- | ------------------------------------- | -------------------------------------------------------------- |
| _(col key)_ | _(col key)_                           | _(dependent requires prerequisite first)_                      |
| present     | result:InlineResult\|SynthesisReceipt | present consumes final result from execute or synthesize phase |

## Input

| Field    | Type                               | Required | Description                                   |
| -------- | ---------------------------------- | -------- | --------------------------------------------- |
| `result` | `InlineResult \| SynthesisReceipt` | yes      | Final result from execute or synthesize phase |

## Output

| Field | Type   | Description                                      |
| ----- | ------ | ------------------------------------------------ |
| —     | `void` | No output; presents to user and writes dashboard |

## Examples

### Happy Path

- Input: { result: SynthesisReceipt { status: "SYNTHESIS_OK", output_file: ".../synthesis.md", summary: "..." } }
- present shows summary to user; dashboard.md created/updated; output_files NOT enumerated unless requested
- Output: void; dashboard.md updated

### Failure Path

- Input: { result: SynthesisReceipt { status: "SYNTHESIS_FAIL", ... } }
- present shows failure summary to user; fault(present_fails) => fallback: none; abort
