# Copilot Instructions

## File Manifest (Lazy Load)

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

- Source of Truth: Resolve conflicts using `core-beliefs.md`, then scoped instruction files.
- Scope Discipline: Apply the smallest viable change set for the requested task.
- Path Discipline: Verify existence before reading or referencing files.
- Note: When creating new files, place them according to established project directory conventions.
  Do not invent unsolicited directory structures.
- Command Discipline: Use only available `mise run` tasks listed in TOOLS.
- Verification Discipline: Run relevant existing checks after modifications.
- Evolution Discipline: When correcting a user-reported mistake, fix the issue AND update
  `.github/instructions/*.md` or `docs/design/*.md` or `docs/adr/*.md` to prevent recurrence.

## Tools

- Lint: [mise run lint]
- Format: [mise run format]

## Workflow

- Read: Open File Manifest entries and extract constraints relevant to the task.
- Plan: Define minimal edits and map each edit to a verified file path.
- Execute: Implement focused changes.
- Verify: Run `mise run lint` and `mise run format` for changed code/docs when applicable.
- Evolve (Conditional): If triggered by a user-reported mistake, extract the missing
  constraint and execute Evolution Discipline.
- Finalize: Confirm outputs match requested scope and repository state is clean.
