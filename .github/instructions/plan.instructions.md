---
applyTo: "docs/plans/**"
---

# Plan Files

## Template Compliance

- Requirement: Before creating any file under `docs/plans/`, read `docs/templates/plan.md` and strictly follow its structure.
- Frontmatter: Required key `status` (value: `TODO`, `IN_PROGRESS`, or `DONE`). No additional keys.
- Sections: Required in order `## Goal`, `## Ref`, `## Steps`, `## Verify`, `## Scratchpad`.
- Restrictions: No sections other than the five above. Do not add sections like Context, Objectives, Scope,
  Requirements, Architecture, Risks, or Appendix.

## Naming Convention

- Pattern: `[YYYY-MM-DD]-[action].md` (e.g., `2026-02-22-fix-ci-mise.md`).
- Location Active: `docs/plans/active/` for in-progress plans.
- Location Done: `docs/plans/done/` for completed plans.
- Transition: When a plan's status changes to `DONE`, move the file from `docs/plans/active/` to `docs/plans/done/`.

## Content Rules

- GOAL: One sentence only.
- REF: List of relevant file paths. Use backtick-quoted paths.
- STEPS: Checkbox list `- [ ] Step N: ...`. One action per step.
- VERIFY: Single verification command or condition.
- SCRATCHPAD: Agent workspace for notes. Free-form.
