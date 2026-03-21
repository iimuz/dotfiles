---
applyTo: "docs/plans/**"
---

# Plan Files

## Template Compliance

- Before creating any file under `docs/plans/`, read `docs/templates/plan.md` and strictly follow its structure.
- Frontmatter requires the key `status` with value `TODO`, `IN_PROGRESS`, or `DONE`. No additional keys.
- Required sections in order: `## Goal`, `## Ref`, `## Steps`, `## Verify`,
  `## Scratchpad`. Do not remove, rename, or reorder these sections.
- Optional sections may be added between `## Verify` and `## Scratchpad` when needed. Use descriptive names.

## Lifecycle

- Set frontmatter `status` to `IN_PROGRESS` when starting work on a plan file.
- Update the plan file at each step: check off completed steps in `## Steps` and write notes in `## Scratchpad` or `## Log`.
- On finalize: Confirm `## Steps` reflects all completed work. Add a
  `## Summary` section between `## Verify` and optional sections containing a
  one-paragraph outcome, significant issues with resolutions, and final
  verification result. Do not include implementation details.
- When the user sets status to `DONE`, move the file from `docs/plans/active/` to `docs/plans/done/`.
- Only the user decides when status changes to `DONE`. Do not set `DONE` without explicit user instruction.

## Naming Convention

- Pattern: `[YYYY-MM-DD]-[action].md` (e.g., `2026-02-22-fix-ci-mise.md`).
- Active plans: `docs/plans/active/`.
- Completed plans: `docs/plans/done/`.

## Content Rules

- Goal: One sentence only.
- Ref: List of relevant file paths. Use backtick-quoted paths.
- Steps: Checkbox list `- [ ] Step N: ...`. One action per step.
- Verify: Single verification command or condition.
- Log: Append-only record of issues, corrections, decisions, and findings
  captured during execution. Format entries as subsection headers
  `### [YYYY-MM-DD] Type: Title` where Type is Issue, Correction, Decision, or
  Finding. Follow each header with free-form content describing the context,
  reasoning, and resolution. Do not delete or modify existing log entries.
- Summary: Written at completion by Copilot. Contains outcome paragraph,
  issues list with resolutions, and verification result. Plain prose, no
  checkboxes. Added during finalize.
- Scratchpad: Agent workspace for notes. Free-form.
