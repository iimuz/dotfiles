---
name: review-fix
description: >-
  Process `REVIEW:` inline comments left in code after implementation review.
  Fix each comment locally and remove it. Use after execute-plan when a human
  has added `REVIEW:` annotations to the codebase.
---

# Review Fix

## Overview

Process `REVIEW:` comments that a human has added to source code after a code
review. Apply each local fix, then delete the resolved comment. Do not touch
the planning file and do not handle design-level changes here.

## Process

1. Identify the planning file from the user's prompt (default: `docs/planning.md`).
2. Read the planning file in full if it exists.
3. Search the entire codebase for `REVIEW:` comments.
4. For each `REVIEW:` comment, decide:
   - Can this be resolved with a local code change that does not conflict with the plan?
     → Fix it and delete the comment.
   - Does it require a design change, schema change, API change, or plan update?
     → Do not implement it; report it and recommend running `write-plan` instead.
5. After fixing a comment, verify the comment has been removed from the file.
6. Run lint and tests when available.
7. Confirm no `REVIEW:` comments remain. Report any that were intentionally deferred.

## What review-fix does NOT handle

- Database schema changes
- API design changes
- Data model ownership changes
- Specification changes
- Scope changes
- Architectural changes
- Anything requiring `plan.md` to be updated
- Todo list restructuring
- Re-opening completed tasks

When a `REVIEW:` comment falls into one of these categories, do not implement it.
Report it clearly and instruct the user to run `write-plan` first.

## Constraints

- Never delete a `REVIEW:` comment without implementing the fix it requests.
- Do not add `REVIEW:` comments or leave them in production code.
- Do not add unnecessary comments or JSDoc.
- Do not use `any` or `unknown` without a specific, justified reason.
- If a `REVIEW:` comment conflicts with `plan.md`, follow `plan.md` and report the conflict.
- Run typecheck before finishing. Run lint and tests when available.
- Do not modify the planning file.
