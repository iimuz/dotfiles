---
name: tdd-workflow-summarize
description: Summarize completed TDD cycles into a deterministic structured report.
user-invocable: false
disable-model-invocation: false
---

# TDD Workflow Summarize

## Overview

Produce one deterministic session summary from completed red-green-refactor cycle results by
aggregating counts and deduplicating changed files across the session. Abort when the cycle list is
empty or contains an invalid status, and if file collection cannot be completed return empty file
lists while still producing the summary.

## Input

- `cycles: array<object>` - Completed or failed cycle records with unit status, test counts, and
  created or modified file paths.

## Output

- `summary: object` - Aggregate counts for completed and failed units, total tests added and
  passed, and deduplicated created and modified file lists.

## Examples

- Happy: Two completed cycles and one failed cycle produce a summary with
  `unitsCompleted: 2`, `unitsFailed: 1`, `testsAdded: 3`, `testsPassed: 2`,
  `filesCreated: ['tests/auth_lockout_test.py']`, and
  `filesModified: ['app/auth.py']`.
- Failure: An empty `cycles` list aborts before any summary is generated.
