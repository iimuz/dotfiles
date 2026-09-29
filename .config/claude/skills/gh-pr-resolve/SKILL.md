---
name: gh-pr-resolve
description: Use when resolving or addressing PR review comments.
---

# Resolve PR Review Comments

## Purpose

Provide a method for accurately analyzing pull request review comments.
Determine whether each comment is actionable and, when it is, describe the
concrete change needed.

## Analysis Procedure

### 1. Collect inputs

- Retrieve all unresolved review comments on the target PR.
- For each comment, read the referenced file and surrounding code context.
  Judge each comment from the code, not from the comment text alone.

### 2. Investigate related code

- Search the whole codebase, not only the diff hunks, for locations with the
  same or similar pattern as the flagged code (e.g. duplicated logic, shared
  helpers, copy-pasted blocks).
- Identify callers, callees, and dependents of the code targeted by the comment.
- Determine whether applying the suggested change would require cascading
  modifications in related locations.

### 3. Assess each comment

- Understand what the reviewer is requesting. Keep the reviewer's intent: do not
  reinterpret the comment, extend its scope, or add improvements the reviewer did
  not raise.
- Judge whether the request is valid based on the actual code and the
  related-code investigation from step 2.
- Classify the comment:
  - fix: the comment points to a real issue and a concrete change exists.
  - skip: the comment is ambiguous, subjective, already addressed, or
    no clear change can be derived.
- When in doubt, classify as skip (fail-closed).
- When a better solution than the reviewer's suggestion exists for the same
  issue, include it as an alternative in the output.

## Output Format

Use the template defined in [template](references/template.md).
