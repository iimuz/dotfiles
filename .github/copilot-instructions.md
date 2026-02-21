# Copilot Instructions

## FILE_MANIFEST (Lazy Load)

- Setup Scripts: `setup_*.sh`, `update_*.sh`
- Configurations: `.config/`
- Mise settings: `.mise/`
- Documents: `docs/`
  - Core beliefs: `docs/design/core-beliefs.md`
  - Architecture: `docs/design/architecture.md`
  - Design: `docs/design/`
  - Debt: `docs/debt/`
  - Plans: `docs/plans/`
  - Templates: `docs/templates/`

## DIRECTIVES

- Source of Truth: Resolve conflicts using `core-beliefs.md`, then scoped instruction files.
- Scope Discipline: Apply the smallest viable change set for the requested task.
- Path Discipline: Verify existence before reading or referencing files.
- Note: When creating new files, place them according to established project directory conventions.
  Do not invent unsolicited directory structures.
- Command Discipline: Use only available `mise run` tasks listed in TOOLS.
- Verification Discipline: Run relevant existing checks after modifications.
- Doc Standards: Follow `docs/design/doc-standards.md` for all documentation changes.

## TOOLS

- Lint: [mise run lint]
- Format: [mise run format]

## WORKFLOW

- READ: Open FILE_MANIFEST entries and extract constraints relevant to the task.
- PLAN: Define minimal edits and map each edit to a verified file path.
- EXECUTE: Implement focused changes.
- VERIFY: Run `mise run lint` and `mise run format` for changed code/docs when applicable.
- FINALIZE: Confirm outputs match requested scope and repository state is clean.
