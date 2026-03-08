---
name: tdd-workflow-summarize
description: Summarize completed TDD cycles into a deterministic structured report.
user-invocable: false
disable-model-invocation: false
---

# TDD Workflow Summarize

## Overview

Produce one deterministic session summary from completed red-green-refactor cycle results.
Execution order: validate_cycles -> aggregate_counts -> collect_files -> build_summary.

## Schema

```typescript
type TddCycleResult = Readonly<{
  unitId: string;
  status: "completed" | "failed";
  testsAdded: number;
  testsPassed: number;
  filesCreated: readonly string[];
  filesModified: readonly string[];
}>;

type TddSessionSummary = Readonly<{
  unitsCompleted: number;
  unitsFailed: number;
  testCount: Readonly<{ added: number; passed: number }>;
  files: Readonly<{ created: readonly string[]; modified: readonly string[] }>;
}>;
```

## Constraints

- If cycles list is empty, abort immediately.
- If a cycle contains an invalid status value, abort immediately.
- If file collection fails, return empty file lists and continue.

## Input

| Field    | Type               | Required | Description                            |
| -------- | ------------------ | -------- | -------------------------------------- |
| `cycles` | `TddCycleResult[]` | yes      | Completed or failed unit-cycle records |

## Output

- summary: `TddSessionSummary` with aggregate counts and deduplicated file lists.

## Examples

### Happy Path

- Input includes multiple cycle records with tests and file paths.
- Counts are aggregated and file paths are deduplicated.
- Output returns one deterministic summary object.

### Failure Path

- Input includes no cycles.
- Abort: cycles list is empty.
