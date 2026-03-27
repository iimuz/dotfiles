---
applyTo: "docs/plans/**"
---

# Plan Files

## Template Compliance

- Before creating any file under `docs/plans/`, read `docs/templates/plan.md` and strictly follow its structure.
- Frontmatter has a single optional key `issue` for linking to a GitHub Issue number. No additional keys.
- Required sections in order: `## Goal`, `## Ref`, `## Steps`, `## Verify`,
  `## Log`, `## Scratchpad`. Do not remove, rename, or reorder these sections.
- Optional sections may be added between `## Verify` and `## Log` when needed. Use descriptive names.

## Lifecycle

- Plan files are ephemeral working documents. GitHub Issues are the permanent record.
- Update the plan file at each step: check off completed steps in `## Steps` and write notes in `## Scratchpad` or `## Log`.
- On finalize: Confirm `## Steps` reflects all completed work. Post relevant
  findings and outcomes to the corresponding GitHub Issue as a comment.
- Only the user decides when a plan is complete. Do not delete plan files without explicit user instruction.
- When the user marks a plan as complete, delete the plan file from `docs/plans/`.

## Naming Convention

- Pattern: `[YYYY-MM-DD]-[action].md` (e.g., `2026-02-22-fix-ci-mise.md`).
- Location: `docs/plans/`.

## Content Rules

- Goal: One sentence only.
- Ref: List of relevant file paths. Use backtick-quoted paths.
- Steps: Checkbox list `- [ ] Step N: ...`. One action per step.
- Verify: Single verification command or condition.
- Log: Append-only record of issues, corrections, decisions, and findings
  captured during execution. Free-form bullets or subsection headers as needed.
  Do not delete or modify existing log entries.
- Scratchpad: Agent workspace for notes. Free-form.
