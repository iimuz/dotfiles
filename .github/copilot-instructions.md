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

1. Source of Truth: Resolve conflicts using `core-beliefs.md`, then scoped instruction files.
2. Scope Discipline: Apply the smallest viable change set for the requested task.
3. Path Discipline: Verify existence before reading or referencing files.
   When creating new files, place them according to established project directory conventions.
   Do not invent unsolicited directory structures.
4. Command Discipline: Use only available `mise run` tasks listed in TOOLS.
5. Verification Discipline: Run relevant existing checks after modifications.
6. Doc Standards: Follow `docs/design/doc-standards.md` for all documentation changes.

## TOOLS

- Lint: [mise run lint]
- Format: [mise run format]

## WORKFLOW

1. READ: Open FILE_MANIFEST entries and extract constraints relevant to the task.
2. PLAN: Define minimal edits and map each edit to a verified file path.
3. EXECUTE: Implement focused changes.
4. VERIFY: Run `mise run lint` and `mise run format` for changed code/docs when applicable.
5. FINALIZE: Confirm outputs match requested scope and repository state is clean.
