---
name: tdd-workflow-refactor
description: Refactor safely while preserving behavior with green test proof.
user-invocable: false
disable-model-invocation: false
---

# TDD Workflow: Refactor

## Overview

Improve internal structure after a confirmed green phase while preserving observable behavior,
and prove tests remain green.
Execution order: validate_green_proof -> apply_refactor -> verify_pass_preservation.

## Constraints

- If green proof is absent or evidence is empty, abort immediately.
- If behavior changes during refactor, revert the refactor, restore baseline, and abort.
- If tests fail after refactor, revert the refactor, keep baseline, and abort.

## Input

| Field            | Type     | Required | Description                                    |
| ---------------- | -------- | -------- | ---------------------------------------------- |
| `unitSpec`       | `string` | yes      | Atomic behavior scope for safe refactor bounds |
| `greenPassProof` | `object` | yes      | Verified green evidence from preceding stage   |
| `testCommand`    | `string` | yes      | Command used to verify post-refactor pass      |

## Output

- refactoredFiles: Paths changed during behavior-preserving refactor.
- passPreservationProof: Command, summary, and evidence showing tests still pass.

## Examples

### Happy Path

- Valid green proof is provided.
- Internal cleanup changes are applied without behavioral change.
- testCommand remains green and RefactorOutput is returned.

### Failure Path

- testCommand fails after refactor.
- Revert refactor, keep baseline, and abort.
