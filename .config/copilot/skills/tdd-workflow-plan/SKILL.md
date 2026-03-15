---
name: tdd-workflow-plan
description: Decompose feature requests into atomic TDD red-green-refactor units.
user-invocable: false
disable-model-invocation: false
---

# TDD Workflow Plan

## Overview

Transform a concrete feature request into an ordered list of atomic TDD units so each unit
covers one observable behavior, one test path, one test command, and one implementation target.
Abort when the request is empty or no atomic behavior can be extracted, and when unit metadata is
incomplete regenerate missing fields once before failing; if ordering conflicts appear, prefer the
lowest-dependency behavior first and continue with a deterministic sequence.

## Input

- `featureRequest: string` - Natural-language feature statement such as account lockout after
  repeated login failures.
- `constraints: string | undefined` - Optional domain limits such as keep the lockout window at
  ten minutes.
- `acceptanceCriteria: string | undefined` - Optional observable outcomes such as the fifth failed
  login returns HTTP 429.

## Output

- `orderedUnits: array<object>` - Ordered atomic units with behavior, test path, test command,
  expected failure, implementation path, refactor scope, and done condition.

## Examples

- Happy: "Lock an account for 10 minutes after 5 failed logins" becomes ordered
  units for counting failures, denying the sixth attempt, and clearing the lock
  after the timeout.
- Failure: "Make auth better somehow" aborts because no atomic observable behavior can be extracted.
