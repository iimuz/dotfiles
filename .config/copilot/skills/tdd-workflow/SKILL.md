---
name: tdd-workflow
description: Coordinates strict red-green-refactor delivery for feature requests when users ask to implement or fix behavior with test-first TDD evidence, staged gate checks, and end-to-end cycle reporting.
user-invocable: true
disable-model-invocation: false
---

# TDD Workflow Orchestrator

## Overview

User-facing workflow skill that coordinates full TDD execution:
plan one feature into units, run red -> green -> refactor per unit,
enforce hard gates between stages, abort on first failing unit,
preserve completed unit results, and produce one deterministic summary.

## Interface

```typescript
/**
 * @skill tdd-workflow
 * @input  TddWorkflowInput
 * @output TddWorkflowOutput
 *
 * @invariants
 * - invariant: (subagent_spawns_subagent) => abort("Sub-skills must not call task() or spawn nested sub-agents");
 * - invariant: (main_invokes_skill_tool) => abort("Main agent must not call skill() tool; sub-agents invoke skills themselves");
 * - invariant: (main_reads_intermediate_files) => abort("Main agent reads only final TddWorkflowOutput; not sub-skill outputs directly");
 */

type Severity =
  | { kind: "abort"; reason: string }
  | { kind: "warn"; reason: string };

type WorkflowStatus = "completed" | "aborted";

type TddWorkflowInput = {
  featureRequest: string;
  constraints?: readonly string[];
  acceptanceCriteria?: readonly string[];
};

type PlannedUnit = {
  id: string;
  behavior: string;
  testPath: string;
  testCommand: string;
  expectedFailure: string;
  implementationPath: string;
  refactorScope: string;
  doneWhen: string;
};

type PlanStageOutput = {
  ordered_units: readonly PlannedUnit[];
};

type RedStageProof = {
  command: string;
  observedFailure: string;
};

type GreenStageProof = {
  command: string;
  summary: string;
  evidence: string;
};

type RefactorStageProof = {
  passPreservationProof: {
    command: string;
    summary: string;
    evidence: string;
  };
};

type UnitCycleResult = {
  unitId: string;
  behavior: string;
  status: "completed" | "failed";
  red: RedStageProof;
  green?: GreenStageProof;
  refactor?: RefactorStageProof;
  filesCreated: readonly string[];
  filesModified: readonly string[];
  testsAdded: number;
  testsPassed: number;
};

type SummaryStageOutput = {
  summary: {
    unitsCompleted: number;
    unitsFailed: number;
    testCount: {
      added: number;
      passed: number;
    };
    files: {
      created: readonly string[];
      modified: readonly string[];
    };
  };
};

type TddWorkflowOutput = {
  status: WorkflowStatus;
  completedCycles: readonly UnitCycleResult[];
  failedUnitId?: string;
  failure?: Severity;
  summary?: SummaryStageOutput;
};
```

## Severity Model

```typescript
function abort(reason: string): Severity {
  return { kind: "abort", reason };
}

function warn(reason: string): Severity {
  return { kind: "warn", reason };
}
```

## Sub-Skill Delegation

| Stage     | Skill                    | Purpose                                                | Input                           | Output                      |
| --------- | ------------------------ | ------------------------------------------------------ | ------------------------------- | --------------------------- |
| plan      | `tdd-workflow-plan`      | Decompose feature into ordered atomic units.           | `TddWorkflowInput`              | `PlanStageOutput`           |
| red       | `tdd-workflow-red`       | Write one failing test and collect failure proof.      | unit spec                       | red proof                   |
| green     | `tdd-workflow-green`     | Implement minimal code and prove tests pass.           | unit + red proof + test command | green pass proof            |
| refactor  | `tdd-workflow-refactor`  | Refactor safely while preserving green state.          | unit + green proof              | refactor preservation proof |
| summarize | `tdd-workflow-summarize` | Aggregate all cycle results into deterministic report. | all cycle results               | `SummaryStageOutput`        |

## Operations

```typespec
op planStage(input: TddWorkflowInput) -> PlanStageOutput {
  // Invoke skill("tdd-workflow-plan") to generate ordered_units from the feature request.
  // This stage is mandatory and drives loop sequencing.

  fault(plan_skill_failed) => fallback: none; abort
}

op loopStage(plan: PlanStageOutput) -> { completedCycles: UnitCycleResult[]; failedUnitId?: string } {
  // For each unit in ordered_units, execute exactly one red -> green -> refactor cycle.
  // Persist successful cycle results immediately.
  // Partial-completion policy: abort on first unit failure and keep all prior completedCycles.

  fault(unit_cycle_failed) => fallback: persist completedCycles and stop at failing unit; continue
}

op redGreenRefactorCycle(unit: PlannedUnit) -> UnitCycleResult {
  // 1) red: invoke skill("tdd-workflow-red") and collect failure proof.
  // 2) green: invoke skill("tdd-workflow-green") only if red failure proof exists.
  // 3) refactor: invoke skill("tdd-workflow-refactor") only if green pass proof exists.

  // Hard gate 1: Green requires Red proof.
  fault(red_failure_proof_absent) => fallback: none; abort

  // Hard gate 2: Refactor requires Green proof.
  fault(green_pass_proof_absent) => fallback: none; abort

  fault(red_skill_failed) => fallback: none; abort
  fault(green_skill_failed) => fallback: none; abort
  fault(refactor_skill_failed) => fallback: none; abort
}

op summarizeStage(cycles: UnitCycleResult[]) -> SummaryStageOutput {
  // Invoke skill("tdd-workflow-summarize") with all persisted cycle results.
  // Include both completed and failed status records when present.

  fault(summarize_skill_failed) => fallback: emit warn("summary unavailable; return cycle records only"); continue
}

op orchestrate(input: TddWorkflowInput) -> TddWorkflowOutput {
  // planStage -> loopStage -> summarizeStage
  // Enforcement: only this orchestrator may call task(); delegated sub-skills must not call task().
  // Enforcement: sub-agents invoked by delegated sub-skills must not make nested task() calls.

  fault(orchestrator_task_call_outside_root) => fallback: none; abort
}
```

## Execution

### Phase 1: Plan

```text
task(agent_type: "general-purpose", model: "claude-opus-4.6",
     prompt: "Use the skill tool to invoke 'tdd-workflow-plan' with input:
              { featureRequest: input.featureRequest,
                constraints: input.constraints,
                acceptanceCriteria: input.acceptanceCriteria }")
```

Read `ordered_units` from the returned `PlanStageOutput`.

```text
fault(plan_skill_failed) => fallback: none; abort
```

### Phase 2: Loop (per unit in ordered_units)

For each `unit` in `ordered_units`, execute 2a → 2b → 2c in sequence.

#### Phase 2a: Red

```text
task(agent_type: "general-purpose", model: "gpt-5.3-codex",
     prompt: "Use the skill tool to invoke 'tdd-workflow-red' with input:
              { unitSpec: { behavior: unit.behavior, testPath: unit.testPath,
                testCommand: unit.testCommand,
                expectedFailure: unit.expectedFailure } }")
```

```text
fault(red_skill_failed) => fallback: none; abort
fault(red_failure_proof_absent) => fallback: none; abort
```

#### Phase 2b: Green (requires Red proof)

```text
task(agent_type: "general-purpose", model: "gpt-5.3-codex",
     prompt: "Use the skill tool to invoke 'tdd-workflow-green' with input:
              { unitSpec: unit.behavior,
                redFailureProof: RedOutput.failureProof,
                testCommand: unit.testCommand,
                implementationPath: unit.implementationPath }")
```

```text
fault(green_skill_failed) => fallback: none; abort
fault(green_pass_proof_absent) => fallback: none; abort
```

#### Phase 2c: Refactor (requires Green proof)

```text
task(agent_type: "general-purpose", model: "gpt-5.3-codex",
     prompt: "Use the skill tool to invoke 'tdd-workflow-refactor' with input:
              { unitSpec: unit.behavior,
                greenPassProof: GreenOutput.passProof }")
```

```text
fault(refactor_skill_failed) => fallback: none; abort
```

#### Loop-level guard

```text
fault(unit_cycle_failed) => fallback: persist completedCycles and stop at failing unit; continue
```

### Phase 3: Summarize

```text
task(agent_type: "general-purpose", model: "claude-opus-4.6",
     prompt: "Use the skill tool to invoke 'tdd-workflow-summarize' with input:
              { cycles: completedCycles }")
```

```text
fault(summarize_skill_failed) => fallback: emit warn("summary unavailable"); continue
```

### Pipeline Summary

```text
phase1_plan -> phase2_loop [for unit in ordered_units: 2a_red -> 2b_green -> 2c_refactor] -> phase3_summarize
```

| dependent        | prerequisite   | description                                      |
| ---------------- | -------------- | ------------------------------------------------ |
| _(column key)_   | _(column key)_ | _(dependent requires prerequisite first)_        |
| phase2_loop      | phase1_plan    | loop requires ordered_units from plan            |
| 2b_green         | 2a_red         | green requires red failure proof (hard gate)     |
| 2c_refactor      | 2b_green       | refactor requires green pass proof (hard gate)   |
| phase3_summarize | phase2_loop    | summarize aggregates all completed cycle results |

## Examples

### Happy Path

- Input: feature request decomposes into 3 units.
- Each unit runs red -> green -> refactor with required proof gates satisfied.
- No unit fails; summarize stage returns deterministic session summary.
- Output: status=`completed`, completedCycles=3, summary included.

### Failure Path

- Unit 2 red stage returns without failure proof.
- Green hard gate blocks execution for Unit 2.
- fault(red_failure_proof_absent) => fallback: none; abort.
- Output: status=`aborted`, completedCycles persisted for Unit 1 only.
