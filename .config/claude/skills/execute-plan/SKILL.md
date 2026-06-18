---
name: execute-plan
description: >-
  Implement the plan defined in a planning file.
  Use only after the plan is fully reviewed and approved.
---

# Execute Plan

## Overview

Implement all tasks defined in the planning file without stopping mid-way.
The latest planning file is the single source of truth. Do not deviate from it.

## Process

1. Identify the planning file from the user's prompt (default: `docs/planning.md`).
2. Read the planning file in full. Always use the latest version.
3. Read any research files referenced in the plan.
4. Read implementation files and related code relevant to the plan.
5. Implement all unchecked tasks in order, including tasks that were re-opened by a
   post-implementation review.
6. For each task or phase, follow the plan's described change, verification, and
   completion criteria.
7. After completing each task or phase, mark it as completed in the planning file.
8. Continue until all tasks and phases are completed. Do not stop for confirmation.

## Constraints

- Do not stop mid-way to ask for confirmation.
- Do not add features beyond what the plan specifies.
- Do not add unnecessary comments.
- Do not reorder, merge, or skip tasks unless the plan explicitly allows it.
- Do not defer verification to the end when the plan attaches verification to specific
  tasks or phases.
- Mark each task completed immediately after finishing it, not in batch.
- Mark a task completed only after its verification and completion criteria are satisfied.
- If a task is ambiguous, use the most conservative interpretation.
- Do not process `REVIEW:` comments in code — that is the responsibility of `review-fix`.
- If the planning file contains unresolved `PLAN_REVIEW:` annotations or design-level
  conflicts, stop and run `write-plan` first before proceeding.
