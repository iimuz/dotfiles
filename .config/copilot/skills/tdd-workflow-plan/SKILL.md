---
name: tdd-workflow-plan
description: Decompose feature requests into atomic TDD red-green-refactor units.
user-invocable: false
disable-model-invocation: false
---

# TDD Workflow Plan

## Overview

Transform a feature request into an ordered list of atomic TDD units so each unit maps to one
behavior and one red-green-refactor cycle.
Execution order: parse_request -> split_behaviors -> build_units -> order_units.

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
```

## Constraints

- If feature request is missing or empty, abort immediately.
- If no atomic behavior can be extracted, abort immediately.
- If unit mapping is incomplete, regenerate missing fields; if still incomplete, abort.
- If ordering conflicts occur, prioritize lowest-dependency behavior first and continue.

## Input

| Field                | Type     | Required | Description                                   |
| -------------------- | -------- | -------- | --------------------------------------------- |
| `featureRequest`     | `string` | yes      | Natural-language feature statement            |
| `constraints`        | `string` | no       | Optional non-functional or domain constraints |
| `acceptanceCriteria` | `string` | no       | Optional observable success criteria          |

## Output

- orderedUnits: Ordered, atomic TDD units with test and implementation metadata.

## Examples

### Happy Path

- Input describes login lockout after repeated failures.
- Behaviors are split into independent validation units.
- orderedUnits contains deterministic unit order and complete metadata.

### Failure Path

- Input is too vague to extract observable behavior.
- Abort: feature request is empty or no atomic behavior extractable.
