---
name: execute-plan
description: >-
  Implement the plan defined in a planning file.
  Use only after the plan is fully reviewed and approved.
user-invocable: true
disable-model-invocation: false
---

# Execute Plan

## Overview

Implement all tasks defined in the planning file without stopping mid-way.
The plan is the single source of truth. Do not deviate from it.

## Process

1. Identify the planning file from the user's prompt (default: `docs/planning.md`).
2. Read the planning file in full.
3. Read any research files referenced in the plan.
4. Read implementation files and related code relevant to the plan.
5. Implement all unchecked tasks in order.
6. After completing each task or phase, mark it as completed in the planning file.
7. Continue until all tasks and phases are completed. Do not stop for confirmation.

## Constraints

- Do not stop mid-way to ask for confirmation.
- Do not add features beyond what the plan specifies.
- Do not add unnecessary comments.
- Mark each task completed immediately after finishing it, not in batch.
- If a task is ambiguous, use the most conservative interpretation.
