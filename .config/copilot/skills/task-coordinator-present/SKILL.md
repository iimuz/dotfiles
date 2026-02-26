---
name: task-coordinator-present
description: Present execution results and manage run dashboard.
user-invocable: false
disable-model-invocation: true
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

// Mirrored from task-coordinator (canonical source)
type WorkerReceipt = {
  status: "WORKER_OK" | "WORKER_FAIL";
  id: string;
  reason?: string;
};
type InlineResult = WorkerReceipt;
type SynthesisReceipt = {
  status: "SYNTHESIS_OK" | "SYNTHESIS_FAIL";
  output_file: string;
  summary: string;
  /* 2-4 sentences */ reason?: string;
};
```

## Operations

```typespec
op present(result: InlineResult | SynthesisReceipt) -> void {
  // Show inline result or receipt summary to user; write dashboard.md
  invariant: (dashboard_missing)  => create(dashboard_path, "Pending/Questions/Completed structure");
  invariant: (dashboard_exists)   => update(dashboard_path);
  invariant: (run_dirs_count > 5) => prune_oldest("after successful synthesis; retain last 5 runs");
  invariant: (enumerates_retained_run_files and !explicit_user_request) => abort("Do not enumerate retained run files without user request");
}
```

## Execution

```text
present
```
