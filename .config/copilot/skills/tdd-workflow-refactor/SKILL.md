---
name: tdd-workflow-refactor
description: Refactor safely while preserving behavior with green test proof.
user-invocable: false
disable-model-invocation: false
---

# tdd-workflow-refactor

## Overview

Use this sub-skill to improve structure after a confirmed green phase while preserving observable behavior.
For refactor constraints, read [tdd-rules.md](references/tdd-rules.md).

## Interface

```typescript
/**
 * @skill tdd-workflow-refactor
 * @input  { unitSpec: string; greenPassProof: { command: string; summary: string; evidence: string } }
 * @output { refactoredFiles: ReadonlyArray<string>; passPreservationProof: { command: string; summary: string; evidence: string } }
 *
 * @invariants
 * - invariant: (task_call_attempted) => abort("Sub-skill must not call task() or spawn nested sub-agents");
 */

interface RefactorInput {
  unitSpec: string;
  greenPassProof: {
    command: string;
    summary: string;
    evidence: string;
  };
}

interface RefactorOutput {
  refactoredFiles: ReadonlyArray<string>;
  passPreservationProof: {
    command: string;
    summary: string;
    evidence: string;
  };
}
```

## Ops

### Op 1: Validate refactor preconditions

- Input: RefactorInput.
- Action: Confirm unitSpec exists and greenPassProof contains command, summary, and evidence
  proving tests are currently green.
- Output: Refactor is authorized only when green evidence is present.
- fault(green pass proof absent) => fallback: request fresh green test run proof; abort

### Op 2: Apply behavior-preserving refactor

- Input: Authorized refactor scope from Op 1.
- Action: Refactor only internal structure, readability, and duplication; keep all public
  outputs, side effects, and interfaces unchanged.
- Output: Updated files with no intentional behavior change.
- fault(behavior changed) => fallback: revert refactor and restore previous implementation; abort

### Op 3: Prove pass preservation

- Input: Refactored files and original test command.
- Action: Re-run tests and capture command output as pass-preservation proof.
- Output: RefactorOutput with refactoredFiles and passPreservationProof.
- fault(tests fail after refactor) => fallback: revert refactor and keep pre-refactor state; abort

## Examples

### Happy Path

- Input includes unitSpec and greenPassProof from a successful test run.
- Skill performs internal cleanup without changing observable behavior.
- Same test command passes after refactor.
- Output returns changed file paths plus new passing test evidence.

### Failure Path

- Input omits greenPassProof evidence.
- Hard gate triggers immediately.
- No refactor is performed.
- Skill aborts and requests valid green proof.
