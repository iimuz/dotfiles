---
name: tdd-workflow
description: Coordinates strict red-green-refactor delivery for feature requests when users ask to implement or fix behavior with test-first TDD evidence, staged gate checks, and end-to-end cycle reporting.
user-invocable: true
disable-model-invocation: false
---

# TDD Workflow Orchestrator

## Overview

Coordinate one strict TDD run by turning a feature request into ordered units, executing
red-green-refactor cycles sequentially, and returning one deterministic workflow result.
Abort immediately if planning fails, stop on the first failed unit cycle while preserving
completed cycle results, omit the summary if summarization fails, require a non-empty
feature request and unit identifiers, and never allow delegated sub-skills to call task().

## Input

- `featureRequest: string` - Feature or bug-fix request expressed as behavior.
- `constraints?: readonly string[]` - Optional implementation constraints.
- `acceptanceCriteria?: readonly string[]` - Optional externally observable success criteria.

## Output

- `status: "completed" | "aborted"` - Final workflow state.
- `completedCycles: readonly object[]` - Completed unit cycle results in execution order.
- `failedUnitId?: string` - Unit identifier present only when a cycle fails.
- `failure?: string` - Failure reason when status is `"aborted"`.
- `summary?: object` - Deterministic aggregate included only when summarization succeeds.

## Execution Flow

### Stage 1: Plan

Decompose the request into a deterministic, non-empty ordered unit list that can be executed
as strict TDD cycles. Each unit must stay small, observable, and independently completable so
the later loop can run one cycle at a time without branching.

task(general-purpose, model=claude-opus-4.6):

> Invoke skill `tdd-workflow-plan` with `{ featureRequest, constraints, acceptanceCriteria }`.
> Return a deterministic ordered unit list. Reject empty input, reject empty unit IDs, and do
> not call `task()` from the delegated skill.

- Output: `orderedUnits: readonly object[]`
- Fault: Abort immediately if planning fails, produces no units, or returns an invalid unit.

### Stage 2: Execute Unit Cycle

For each planned unit in order, run one simple sequential loop: red, then green, then
refactor. Preserve completed cycle results exactly as produced, require each phase to justify
the next, and stop the workflow at the first failed cycle without attempting later units.

task(general-purpose, model=claude-opus-4.6):

> Execute the planned units sequentially. For each unit, invoke sub-skills `tdd-workflow-red`,
> then `tdd-workflow-green`, then `tdd-workflow-refactor` in that exact order, and never call
> `task()` from those delegated sub-skills. Require red failure proof before green, require
> green passing proof before refactor, preserve already completed cycle results, and stop on the
> first failed cycle while returning the failed unit ID and failure reason.

- Output: `completedCycles: readonly object[]`, `failedUnitId?: string`, `failure?: string`
- Fault: Abort on the first failed cycle after preserving all previously completed cycle results.

### Stage 3: Summarize

Aggregate the completed cycle results into one deterministic summary that reports what was
planned, what completed, what failed if anything, and the resulting test and file impact
without changing the preserved cycle outputs.

task(general-purpose, model=gemini-3-pro-preview):

> Invoke skill `tdd-workflow-summarize` with `{ cycles: completedCycles, failedUnitId, failure }`
> and return a deterministic summary. Do not call `task()` from the delegated skill.

- Output: `summary?: object`
- Fault: If summarization fails, return without `summary` and continue with the existing result.

## Examples

- Happy: `featureRequest: "Add slug validation to note creation"` plans two units,
  both cycles complete with red-green-refactor evidence, and summary reports
  `status: "completed"`.
- Failure: `featureRequest: "Reject empty project names"` plans one unit,
  `tdd-workflow-red` cannot produce the expected failing proof, and the workflow
  returns `status: "aborted"` with `failedUnitId: "reject-empty-name"` and no
  summary.
- Failure: `featureRequest: "Normalize tag casing"` completes one cycle
  successfully, `tdd-workflow-summarize` fails, and the workflow still returns
  the completed cycle result without `summary`.
