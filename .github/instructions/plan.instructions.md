---
applyTo: "docs/plans/**"
---

# Plan Files

## Template Compliance

- Requirement: Before creating any file under `docs/plans/`, read `docs/templates/plan.md` and strictly follow its structure.
- Frontmatter: Required key `status` (value: `TODO`, `IN_PROGRESS`, or `DONE`). No additional keys.
- Sections: Required in order `## Goal`, `## Ref`, `## Steps`, `## Verify`,
  `## Scratchpad`. Required sections MUST NOT be removed, renamed, or reordered.
- Optional Sections: MAY add sections between `## Verify` and `## Scratchpad` when needed. Use descriptive names.

## Lifecycle

- On Open: Set frontmatter `status` to `IN_PROGRESS` when starting work on a plans file.
- During Execute: ALWAYS update the plans file at each step: check off completed
  steps in `## Steps` and write notes in `## Scratchpad` or `## Log`.
- On Finalize: Confirm `## Steps` reflects all completed work. Add a `## Summary`
  section (between `## Verify` and optional sections) containing: one-paragraph
  outcome, significant issues with resolutions, final verification result. NEVER
  include implementation details.
- On Done: When the user sets status to `DONE`, move the file from `docs/plans/active/` to `docs/plans/done/`.
- Ownership: ONLY the user decides when status changes to `DONE`. NEVER set `DONE` without explicit user instruction.

## Naming Convention

- Pattern: `[YYYY-MM-DD]-[action].md` (e.g., `2026-02-22-fix-ci-mise.md`).
- Location Active: `docs/plans/active/` for in-progress plans.
- Location Done: `docs/plans/done/` for completed plans.

## Content Rules

- GOAL: One sentence only.
- REF: List of relevant file paths. Use backtick-quoted paths.
- STEPS: Checkbox list `- [ ] Step N: ...`. One action per step.
- VERIFY: Single verification command or condition.
- LOG: Append-only record of issues, corrections, decisions, and findings
  captured during execution. ALWAYS format entries as subsection headers:
  `### [YYYY-MM-DD] Type: Title` where Type is Issue, Correction, Decision,
  or Finding. Follow each header with free-form content describing the
  context, reasoning, and resolution. NEVER delete or modify existing
  log entries.
- SUMMARY: Written at completion by Copilot. Contains: outcome paragraph,
  issues list with resolutions, verification result. Plain prose, no checkboxes.
  Added by Copilot during On Finalize.
- SCRATCHPAD: Agent workspace for notes. Free-form.
