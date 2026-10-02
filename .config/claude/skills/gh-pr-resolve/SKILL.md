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
- Classify the comment, checking fix first, then answer, then skip as the
  leftover:
  - fix: the comment points to a real issue and a concrete change exists.
    A comment phrased as a question ("isn't this X?") is still fix when the
    investigation yields a concrete change.
  - answer: not fix, and the investigation gives a definite reason no change
    is needed. A reply resolves it. This covers questions, confirmation
    requests, already-addressed comments, and claims the investigation
    disproves.
  - skip: not fix and not answer. The comment is too ambiguous or subjective
    for the investigation to settle, or the reviewer's intent cannot be
    determined.
- When in doubt, classify as skip (fail-closed).
- For answer and skip, write the Reason as a reply to the reviewer: what was
  checked and why no change follows. Posting the reply is a separate step that
  needs the user's instruction.
- When the comment cites a written convention or principle (for example a
  doc-conventions rule or an ADR), judge the comment against that convention.
  The same pattern existing elsewhere in the code or documents is not a reason
  to leave it as is.
- When a better solution than the reviewer's suggestion exists for the same
  issue, include it as an alternative in the output.

## Output Format

Use the template defined in [template](references/template.md).
