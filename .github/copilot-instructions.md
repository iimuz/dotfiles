# Copilot Instructions

## File Manifest

- Setup Scripts: `setup_*.sh`, `update_*.sh`
- Configurations: `.config/`
- Mise Settings: `.mise/`
- Documents: `docs/`
  - Core Beliefs: `docs/design/core-beliefs.md`
  - Architecture: `docs/design/architecture.md`
  - Design: `docs/design/`
  - Debt: `docs/debt/`
  - Plans: `docs/plans/`
  - Templates: `docs/templates/`

## Directives

- Resolve conflicts using `core-beliefs.md`, then scoped instruction files.
- Apply the smallest viable change set for the requested task.
- Verify file existence before reading or referencing files.
- When creating new files, place them according to established project directory conventions. Do not invent unsolicited directory structures.
- Use only available `mise run` tasks listed in Tools section.
- Run relevant existing checks after modifications.

### Content Routing

- Place plan files in `docs/plans/active/` (in-progress) or `docs/plans/done/` (completed).
- Place debt files in `docs/debt/open/` (active) or `docs/debt/resolved/` (resolved).
- Do not embed plan content in non-plan files.
- Do not embed debt content in non-debt files.

## Tools

- Lint: `mise run lint`
- Format: `mise run format`

## Workflow

1. Read: Open file manifest entries and extract constraints relevant to the task.
2. Plan: Determine the minimal set of changes needed. Create or open a plan file before executing, except for single-file single-line edits (e.g., typo fix). If the user provided a tagged plan file, use that file. Otherwise, create `docs/plans/active/[YYYY-MM-DD]-[action].md` from `docs/templates/plan.md`.
3. Execute: Implement focused changes.
4. Verify: Run `mise run lint` and `mise run format` after modifications.
