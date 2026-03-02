---
name: tdd-workflow-summarize
description: Summarize completed TDD cycles into a deterministic structured report.
user-invocable: false
disable-model-invocation: false
---

# TDD Workflow Summarize

## Overview

Produce a deterministic session summary from completed red-green-refactor cycle results.

## Interface

```typescript
/**
 * @skill tdd-workflow-summarize
 * @input  { cycles: TddCycleResult[] }
 * @output { summary: TddSessionSummary }
 *
 * @invariants
 * - invariant: (task_call_attempted) => abort("Sub-skill must not call task() or spawn nested sub-agents");
 */
interface TddCycleResult {
  readonly unitId: string;
  readonly status: "completed" | "failed";
  readonly testsAdded: number;
  readonly testsPassed: number;
  readonly filesCreated: readonly string[];
  readonly filesModified: readonly string[];
}

interface TddSessionSummary {
  readonly unitsCompleted: number;
  readonly unitsFailed: number;
  readonly testCount: {
    readonly added: number;
    readonly passed: number;
  };
  readonly files: {
    readonly created: readonly string[];
    readonly modified: readonly string[];
  };
}

/**
 * @deterministic-contract
 * - Same input array values must produce the same output keys, ordering, and counts.
 * - File lists are de-duplicated and sorted lexicographically.
 */
```

## Operations

```typespec
op validate_input(cycles: TddCycleResult[]) -> TddCycleResult[] {
  // Ensure cycles exists and each item matches required fields and enum values.
  fault(cycles.length == 0) => fallback: none; abort
}

op aggregate_counts(cycles: TddCycleResult[]) -> { unitsCompleted: number; unitsFailed: number; added: number; passed: number } {
  // unitsCompleted = count(status == "completed")
  // unitsFailed = count(status == "failed")
  // added = sum(testsAdded); passed = sum(testsPassed)
}

op collect_files(cycles: TddCycleResult[]) -> { created: string[]; modified: string[] } {
  // Flatten filesCreated/filesModified, de-duplicate, and sort ascending.
}

op build_summary(counts, files) -> TddSessionSummary {
  // Emit fixed output structure with keys: unitsCompleted, unitsFailed, testCount, files.
}
```

## Execution

```text
validate_input -> aggregate_counts -> collect_files -> build_summary
```

## Examples

### Happy Path

- Input: 2 cycles, statuses ["completed", "failed"], files and test counts provided.
- Output: { unitsCompleted: 1, unitsFailed: 1, testCount: { added: 5, passed: 3 },
  files: { created: [...], modified: [...] } }.

### Failure Path

- Input: { cycles: [] }.
- fault(cycles.length == 0) => fallback: none; abort.
