---
name: tdd-workflow-green
description: Implements minimal code to pass failing tests with proof.
user-invocable: false
disable-model-invocation: false
---

# TDD Workflow: Green

## Overview

Implement only the smallest production change required to satisfy a verified Red test,
then prove the target test command is green.
Execution order: validate_red_proof -> implement_minimal_change -> verify_green.

## Constraints

- If red proof is absent or empty, abort immediately.
- If unrelated behavior is added during implementation, abort immediately.
- If tests still fail after implementation, abort immediately.

## Input

| Field                | Type     | Required | Description                                |
| -------------------- | -------- | -------- | ------------------------------------------ |
| `unitSpec`           | `string` | yes      | One atomic behavior that must become green |
| `redFailureProof`    | `object` | yes      | Red-phase command and observed failure     |
| `testCommand`        | `string` | yes      | Command used to verify green state         |
| `implementationPath` | `string` | yes      | Target production file to edit             |

## Output

- implementationFile: Updated production file path.
- passProof: Command, summary, and raw passing evidence.

## Examples

### Happy Path

- Input includes unitSpec, valid redFailureProof, testCommand, and implementationPath.
- Minimal implementation change is applied to one production path.
- testCommand passes and passProof is returned.

### Failure Path

- Input omits redFailureProof or proof does not match the unit.
- Abort: red proof is absent or empty.
