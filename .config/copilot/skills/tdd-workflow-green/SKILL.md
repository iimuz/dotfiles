---
name: tdd-workflow-green
description: Implements minimal code to pass failing tests with proof.
user-invocable: false
disable-model-invocation: false
---

# TDD Workflow: Green

## Overview

Implement only the smallest production change required to satisfy a verified Red test, then prove
the target command is green while following the Green-phase constraints in
`references/tdd-rules.md`. Abort if Red proof is missing, if the change adds unrelated behavior,
or if the verification command still fails.

## Input

- `unitSpec: string` - One atomic behavior that must become green, such as returning HTTP 429 on
  the sixth failed login attempt.
- `redFailureProof: object` - Verified Red-phase command, exit status, and failure evidence for
  the targeted behavior.
- `testCommand: string` - Command used to verify the Green result.
- `implementationPath: string` - Production file that receives the minimal change.

## Output

- `implementationFile: string` - Updated production file path.
- `passProof: object` - Command, exit status, and passing evidence that proves the target test is
  green.

## Examples

- Happy: Updating `app/auth.py` makes
  `pytest tests/auth_lockout_test.py -k sixth_attempt` pass after Red proof
  showed `Expected status 429 but received 200`.
- Failure: Editing `app/auth.py` aborts because
  `pytest tests/auth_lockout_test.py -k sixth_attempt` still fails with
  `Expected status 429 but received 200`.
