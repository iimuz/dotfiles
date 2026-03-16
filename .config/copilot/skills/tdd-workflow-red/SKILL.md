---
name: tdd-workflow-red
description: Writes one failing test with verified red-phase failure proof.
user-invocable: false
disable-model-invocation: false
---

# TDD Workflow: Red

## Overview

Create one failing test for one atomic unit and prove it fails for the expected reason before any
production change, following the Red-phase rules in `references/tdd-rules.md`. Abort if the test
cannot be written, if the command passes, or if the observed failure differs from the expected Red
signal.

## Input

- `behavior: string` - Observable behavior targeted by the new test, such as rejecting the sixth
  failed login attempt.
- `testPath: string` - File path where the failing test will be written.
- `testCommand: string` - Command that runs the new test and produces Red evidence.
- `expectedFailure: string` - Expected failure text or signal, such as
  `Expected status 429 but received 200`.

## Output

- `testFile: string` - Path to the newly written failing test file.
- `failureProof: object` - Command, exit status, and observed failure evidence that proves the test
  is Red for the expected reason.

## Examples

- Happy: A test added to `tests/auth_lockout_test.py` fails with
  `Expected status 429 but received 200` after running
  `pytest tests/auth_lockout_test.py -k sixth_attempt`.
- Failure: `pytest tests/auth_lockout_test.py -k sixth_attempt` aborts because
  it fails with `Database unavailable` instead of
  `Expected status 429 but received 200`.
