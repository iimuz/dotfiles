---
applyTo: "docs/planning.md"
---

# Planning File

## Template Compliance

- Before creating `docs/planning.md`, read `docs/templates/planning.md` and strictly follow its structure.
- Frontmatter has a single optional key `issue` for linking to a GitHub Issue number. No additional keys.
- Required sections in order: `## Goal`, `## Ref`, `## Steps`, `## Verify`,
  `## Debt`, `## Log`, `## Scratchpad`. Do not remove, rename, or reorder these sections.
- Optional sections may be added between `## Verify` and `## Debt` when needed. Use descriptive names.

## Lifecycle

- The planning file is an ephemeral working document. GitHub Issues are the permanent record.
- Only one planning file exists at a time at `docs/planning.md`.
- Update the file at each step: check off completed steps in `## Steps` and write notes in `## Scratchpad` or `## Log`.
- Record deferred work items in `## Debt` during execution.
- On finalize: Confirm `## Steps` reflects all completed work. Post relevant
  findings and outcomes to the corresponding GitHub Issue as a comment.
  Create separate GitHub Issues for each item in `## Debt`.
- Only the user decides when a plan is complete. Do not delete `docs/planning.md` without explicit user instruction.

## Content Rules

- Goal: One sentence only.
- Ref: List of relevant file paths. Use backtick-quoted paths.
- Steps: Checkbox list `- [ ] Step N: ...`. One action per step.
- Verify: Single verification command or condition.
- Debt: List of deferred items with brief rationale. Each item should contain enough context to create a GitHub Issue.
- Log: Append-only record of issues, corrections, decisions, and findings
  captured during execution. Free-form bullets or subsection headers as needed.
  Do not delete or modify existing log entries.
- Scratchpad: Agent workspace for notes. Free-form.
