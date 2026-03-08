---
name: tdd-workflow
description: Coordinates strict red-green-refactor delivery for feature requests when users ask to implement or fix behavior with test-first TDD evidence, staged gate checks, and end-to-end cycle reporting.
user-invocable: true
disable-model-invocation: false
---

# TDD Workflow Orchestrator

## Overview

Coordinate one strict TDD run by planning units, executing red-green-refactor cycles in order,
and returning one deterministic workflow result.

## Schema

```typescript
type PlannedUnit = Readonly<{
  id: string;
  behavior: string;
  testPath: string;
  testCommand: string;
  expectedFailure: string;
  implementationPath: string;
  refactorScope: string;
  doneWhen: string;
}>;
type UnitCycleResult = Readonly<{
  unitId: string;
  behavior: string;
  status: "completed" | "failed";
  red: { command: string; observedFailure: string };
  green?: { command: string; summary: string; evidence: string };
  refactor?: { command: string; summary: string; evidence: string };
  filesCreated: readonly string[];
  filesModified: readonly string[];
  testsAdded: number;
  testsPassed: number;
}>;
type TddWorkflowOutput = Readonly<{
  status: "completed" | "aborted";
  completedCycles: readonly UnitCycleResult[];
  failedUnitId?: string;
  failure?: string;
  summary?: Readonly<{
    unitsCompleted: number;
    unitsFailed: number;
    testCount: Readonly<{ added: number; passed: number }>;
    files: Readonly<{
      created: readonly string[];
      modified: readonly string[];
    }>;
  }>;
}>;
```

## Constraints

- If the plan skill fails, abort immediately with no fallback.
- If a unit cycle fails, persist completed cycles, stop the loop, and abort.
- If the summarize skill fails, return output without summary and continue.
- If orchestration fails, abort immediately with no fallback.
- Feature request must not be empty.
- Unit ID must not be empty.
- Sub-skills must not call task().

## Input

- `featureRequest: string`: Feature or bug-fix request expressed as behavior.
- `constraints?: readonly string[]`: Optional implementation constraints.
- `acceptanceCriteria?: readonly string[]`: Optional externally observable success criteria.

## Output

- `status: "completed" | "aborted"`: Completed or aborted.
- `completedCycles: readonly UnitCycleResult[]`: Completed unit results in execution order.
- `failedUnitId?: string`: Present only when a cycle fails.
- `failure?: string`: Failure reason when status is aborted.
- `summary?: TddWorkflowOutput["summary"]`: Deterministic aggregate when summarize stage succeeds.

## Execution

```python
plan = stage_1_plan(input)
completed_cycles = []
for unit in plan["orderedUnits"]:
    cycle = stage_2_cycle(unit)
    if cycle["status"] == "failed":
        return {"status": "aborted", "completedCycles": completed_cycles, "failedUnitId": unit["id"], "failure": "unit_cycle_failed"}
    completed_cycles.append(cycle)
summary = stage_3_summarize(completed_cycles)
return {"status": "completed", "completedCycles": completed_cycles, "summary": summary}
```

### Stage 1: Plan

- Purpose: Build ordered atomic unit plans for strict TDD cycles.
- Inputs: `featureRequest: string`, `constraints?: readonly string[]`, `acceptanceCriteria?: readonly string[]`
- Actions:

  ```yaml
  - tool: task
    agent_type: "general-purpose"
    model: "claude-opus-4.6"
    prompt: >
      Invoke skill tdd-workflow-plan with
      { featureRequest, constraints, acceptanceCriteria }.
      Return the decomposed TDD unit list.
  ```

- Outputs: `orderedUnits: readonly PlannedUnit[]`
- Guards: orderedUnits is deterministic and non-empty.
- Faults:
  - If tdd-workflow-plan fails, abort immediately with no fallback.

### Stage 2: Execute Unit Cycle

- Purpose: Run red-green-refactor for one planned unit with hard proof gates.
- Inputs: `unit: PlannedUnit`
- Actions:

  ```yaml
  - tool: task
    agent_type: "general-purpose"
    model: "claude-opus-4.6"
    prompt: >
      Execute one TDD cycle sequentially: invoke skill
      tdd-workflow-red, then tdd-workflow-green, then
      tdd-workflow-refactor. Return a UnitCycleResult with
      proof fields for each phase.
  ```

- Outputs: `cycle: UnitCycleResult`
- Guards: green requires red proof; refactor requires green proof.
- Faults:
  - If the unit cycle fails, persist completed cycles, stop the loop, and abort.

### Stage 3: Summarize

- Purpose: Aggregate completed cycle results into one deterministic summary.
- Inputs: `completedCycles: readonly UnitCycleResult[]`
- Actions:

  ```yaml
  - tool: task
    agent_type: "general-purpose"
    model: "gemini-3-pro-preview"
    prompt: >
      Invoke skill tdd-workflow-summarize with
      { cycles: completedCycles }.
      Return the TDD cycle summary report.
  ```

- Outputs: `summary: TddWorkflowOutput["summary"]`
- Guards: aggregation is deterministic for identical cycle input.
- Faults:
  - If tdd-workflow-summarize fails, return output without summary and continue.

## Examples

### Happy Path

- Input has one feature with two planned units.
- Stage 1 returns deterministic orderedUnits.
- Stage 2 completes both cycles with red, green, and refactor proofs.
- Stage 3 returns summary and status completed.

### Failure Path

- Stage 2 fails because red proof is missing for one unit.
- fault(unit_cycle_failed) => fallback: persist completed cycles and stop loop; abort.
- Output returns status aborted with failedUnitId and preserved completedCycles.
- Summary is omitted.
