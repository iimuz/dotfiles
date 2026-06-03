---
name: write-plan
description: >-
  Create or refine a planning file. Use to start the planning phase or to
  reflect inline annotations back into an existing plan.
user-invocable: true
disable-model-invocation: false
---

# Write Plan

## Overview

Create a detailed implementation plan, or update an existing plan by processing
inline annotations. Follow the planning template at `references/template.md` as
a starting point — it is intentionally minimal; add sections freely to produce a
complete handoff document.

## Process

### Step 1: Determine Mode

Identify the planning file from the user's prompt (default: `docs/planning.md`).
Read the file if it exists.

- File does not exist → Generate Mode
- File exists, and any of the following apply → Review Revision Mode:
  - User states that review results have been added to a planning file
  - Planning file contains `PLAN_REVIEW:` annotations
  - Plan changes are explicitly required due to post-implementation review
  - Todo list restructuring or task re-opening is required
- File exists, otherwise → Annotate Mode

### Generate Mode

1. Read all research files the user specifies.
2. Read implementation files and related code referenced in the research files.
3. Write the planning file. Include at minimum:
   - Detailed explanation of the approach
   - Code snippets showing the actual changes
   - File paths that will be modified
   - Considerations and trade-offs
     Add any other sections needed for a complete handoff document.

### Annotate Mode

1. Read the planning file in full.
2. Identify all inline annotations the user has added
   (corrections, rejections, additions, domain knowledge).
3. Process each annotation: update the relevant section accordingly.
4. Remove resolved annotation text after incorporating it.

### Review Revision Mode

1. Read the planning file in full.
2. Identify all `PLAN_REVIEW:` annotations and inline annotations.
3. Determine the intent of each annotation.
4. Update the relevant sections of the planning file:
   - approach, modified files, code snippets, trade-offs, risks
   - todo list and task completion status
5. Re-open (uncheck) any completed tasks that require rework due to the review.
6. Remove processed annotations after incorporating them.
7. Append a summary of the review-driven updates to `## Log`.

## Planning File Format

- Use `references/template.md` as a starting point; add sections freely.
- Append notes to `## Log` (never delete or modify existing entries).
- The planning file is ephemeral. GitHub Issues are the permanent record.
- Never delete the planning file without explicit user instruction.

### Plan Quality Rules

A plan must be useful both as a design note and as an implementation guide.

Keep background and design decisions concise but sufficient.
Make the execution plan concrete enough that executing plan does not need to invent missing design.

Before writing the execution plan, choose an execution style:

- TDD: for behavior-heavy and testable changes.
- Staged: for infra/config/schema/generated/mechanical changes.
- Hybrid: for changes that contain both setup work and behavior-heavy logic.

Do not force TDD. Choose based on complexity, risk, and testability.

The execution plan must be ordered by safe build-and-verify sequence, not only by architecture layers.
Avoid generic layer-only plans such as DB → gateway → usecase → controller → tests.

For each non-trivial task, include:

- target files
- concrete change
- expected behavior or contract
- test or verification method
- completion criteria

Do not put all tests only at the end as a generic phase.
Attach tests or verification to the relevant tasks or phases where practical.

## Constraints

- Do NOT write or edit any implementation files.
- Do not implement any part of the plan.
- When review-driven design changes conflict with existing completed tasks, update the
  planning file first and re-open affected tasks; do not leave the plan inconsistent.
- `PLAN_REVIEW:` annotations must not be left in the file after processing.
