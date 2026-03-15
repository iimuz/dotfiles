---
name: tdd-workflow-refactor
description: Refactor safely while preserving behavior with green test proof.
user-invocable: false
disable-model-invocation: false
---

# TDD Workflow: Refactor

## Overview

Improve internal structure after a confirmed Green phase while preserving observable behavior, and
prove the relevant tests stay green under the Refactor-phase rules in `references/tdd-rules.md`.
Abort if Green proof is missing, and if behavior changes or tests fail after refactoring, restore
the pre-refactor baseline before stopping.

## Input

- `unitSpec: string` - Atomic behavior that bounds the safe refactor, such as enforcing the
  sixth-attempt lockout response.
- `greenPassProof: object` - Verified Green evidence from the preceding phase.
- `testCommand: string` - Command used to confirm behavior is preserved after refactoring.

## Output

- `refactoredFiles: array<string>` - Files changed during the behavior-preserving refactor.
- `passPreservationProof: object` - Command, exit status, and passing evidence showing the
  refactor kept the tests green.

## Examples

- Happy: Extracting `increment_failed_attempts` from `app/auth.py` keeps
  `pytest tests/auth_lockout_test.py -k sixth_attempt` green after the Green
  proof already passed.
- Failure: Renaming logic in `app/auth.py` aborts and restores the baseline
  when `pytest tests/auth_lockout_test.py -k sixth_attempt` starts failing with
  `Expected status 429 but received 200`.
