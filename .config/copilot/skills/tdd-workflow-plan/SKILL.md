---
name: tdd-workflow-plan
description: Decompose feature requests into atomic TDD red-green-refactor units.
user-invocable: false
disable-model-invocation: false
---

# TDD Workflow Plan

## Overview

Transform a feature request into an ordered list of atomic TDD units,
where each unit maps to one behavior and one red-green-refactor cycle.

## Interface

```typescript
/**
 * @skill tdd-workflow-plan
 * @input  { featureRequest: string; constraints?: string[]; acceptanceCriteria?: string[] }
 * @output { ordered_units: PlannedUnit[] }
 *
 * @invariants
 * - invariant: (task_call_attempted) => abort("Sub-skill must not call task() or spawn nested sub-agents");
 */

interface TddWorkflowInput {
  featureRequest: string;
  constraints?: string[];
  acceptanceCriteria?: string[];
}

interface PlannedUnit {
  id: string;
  behavior: string;
  testPath: string;
  testCommand: string;
  expectedFailure: string;
  implementationPath: string;
  refactorScope: string;
  doneWhen: string;
}

interface PlanStageOutput {
  ordered_units: PlannedUnit[];
}
```

## Operations

```typespec
op parse_request(input: TddWorkflowInput) -> TddWorkflowInput {
  // Extract explicit behavior, constraints, and acceptance criteria from featureRequest.
  // Normalize language into implementation-ready behavior statements.
  fault(featureRequestMissing) => fallback: none; abort
}

op split_behaviors(parsed: TddWorkflowInput) -> string[] {
  // Split parsed request into atomic, observable behaviors.
  // Ensure each behavior can be validated independently.
  fault(noAtomicBehavior) => fallback: ask for clearer behavior statements; abort
}

op build_tdd_units(behaviors: string[]) -> PlannedUnit[] {
  // Create one unit per behavior with testPath, testCommand, expectedFailure,
  // implementationPath, and refactorScope fields populated.
  // Keep each unit minimal and independent to preserve strict TDD sequencing.
  fault(unitMappingIncomplete) => fallback: regenerate missing fields for affected units; continue
}

op order_units(units: PlannedUnit[]) -> PlanStageOutput {
  // Sort units by dependency and learning risk so earlier cycles unlock later work.
  // Return a deterministic ordered_units list for orchestrated execution.
  fault(orderingConflict) => fallback: prioritize lowest-dependency behavior first; continue
}
```

## Input

- featureRequest: Natural-language feature statement.
- constraints: Optional non-functional or domain constraints.
- acceptanceCriteria: Optional explicit success conditions.

## Output

- ordered_units: Ordered array of atomic PlannedUnit items. Each unit has testPath,
  testCommand, expectedFailure, and implementationPath populated for downstream sub-skills.

## Examples

### Happy Path

- Input: featureRequest="Add login with lockout after 5 failures"
- Output: ordered_units has 3 units: authenticate valid user, reject invalid password, lock account after threshold.
- Result: each unit has testPath, testCommand, expectedFailure, implementationPath populated.

### Failure Path

- Input: feature_request="Improve auth"
- parse_request cannot extract concrete behavior.
- fault(featureRequestMissing) => fallback: none; abort
