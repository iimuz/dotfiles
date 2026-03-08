---
name: tdd-workflow-red
description: Writes one failing test with verified red-phase failure proof.
user-invocable: false
disable-model-invocation: false
---

# TDD Workflow: Red

## Overview

Create one failing test for one atomic unit and prove it fails for the expected reason
before any production change.

## Constraints

- If the test cannot be written, abort immediately.
- If the test does not fail, abort immediately.
- If the observed failure does not match the expected failure, abort immediately.

## Input

| Field             | Type     | Required | Description                            |
| ----------------- | -------- | -------- | -------------------------------------- |
| `behavior`        | `string` | yes      | Observable behavior the test targets   |
| `testPath`        | `string` | yes      | Path where the failing test is written |
| `testCommand`     | `string` | yes      | Command used to execute the new test   |
| `expectedFailure` | `string` | yes      | Expected failure signal for red phase  |

## Output

- testFile: Path to the newly written failing test.
- failureProof: Command and observed failure evidence.

## Examples

### Happy Path

- One test is written at testPath for one behavior.
- testCommand fails with expectedFailure evidence.
- Output returns testFile and failureProof.

### Failure Path

- Test command fails for a different reason than expected.
- Abort: observed failure does not match expected failure.
