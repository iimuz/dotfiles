# Copilot Instructions

## FILE_MANIFEST (Lazy Load)

- SetupScripts: `setup_*.sh`, `update_*.sh`
- Configurations: `.config/`
- MiseSettings: `.mise/`
- Documents: `docs/`
  - CoreBeliefs: `docs/design/core-beliefs.md`
  - Architecture: `docs/design/architecture.md`
  - Design: `docs/design/`
  - Debt: `docs/debt/`
  - Plans: `docs/plans/`
  - Templates: `docs/templates/`

## DIRECTIVES

- SourceOfTruth: Resolve conflicts using `core-beliefs.md`, then scoped instruction files.
- ScopeDiscipline: Apply the smallest viable change set for the requested task.
- PathDiscipline: Verify existence before reading or referencing files.
- Note: When creating new files, place them according to established project directory conventions.
  Do not invent unsolicited directory structures.
- CommandDiscipline: Use only available `mise run` tasks listed in TOOLS.
- VerificationDiscipline: Run relevant existing checks after modifications.
- EvolutionDiscipline: When correcting a user-reported mistake, fix the issue AND update
  `.github/instructions/*.md` or `docs/design/*.md` or `docs/adr/*.md` to prevent recurrence.

## TOOLS

- Lint: [mise run lint]
- Format: [mise run format]

## WORKFLOW

- Read: Open FILE_MANIFEST entries and extract constraints relevant to the task.
- Plan: Define minimal edits and map each edit to a verified file path.
- Execute: Implement focused changes.
- Verify: Run `mise run lint` and `mise run format` for changed code/docs when applicable.
- Evolve (Conditional): If triggered by a user-reported mistake, extract the missing
  constraint and execute EvolutionDiscipline.
- Finalize: Confirm outputs match requested scope and repository state is clean.
