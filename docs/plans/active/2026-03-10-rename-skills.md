---
status: IN_PROGRESS
---

# TASK: Rename Copilot Skills

## Goal

- Goal: Rename two skill directories and update all related references and skill documentation.

## Ref

- `.config/copilot/skills/draft-review/SKILL.md`
- `.config/copilot/skills/resolve-comments/SKILL.md`
- `.config/copilot/skills/draft-review/scripts/create_review.sh`
- `.config/copilot/skills/draft-review/scripts/create_review.py`
- `.github/instructions/skills.instructions.md`
- `.github/copilot-instructions.md`
- `.config/copilot/copilot-instructions.md`

## Steps

- [x] Step 1: Read current skill files and related instructions.
- [x] Step 2: Rename skill directories and update frontmatter names.
- [x] Step 3: Update draft-review SKILL.md to describe script invocation and required arguments.
- [x] Step 4: Update resolve-comments SKILL.md and all repository references to old names.
- [x] Step 5: Run lint and format, then verify final names.

## Verify

- Verify: Run `mise run lint` and `mise run format` and confirm renamed SKILL `name` fields match directory names.

## Summary

Renamed both requested skill directories and updated each renamed SKILL frontmatter `name`
to match its directory. Replaced old skill-name references with the new names. Updated
`draft-review/SKILL.md` to document script invocation and required CLI arguments without
exposing implementation details. Verification succeeded with `mise run format` and
`mise run lint`, and final checks confirmed no remaining `pr-review-draft` or
`review-comment-workflow` references.

## Scratchpad

- Description: Perform the requested renames first, then update SKILL documentation and global references, then verify.
