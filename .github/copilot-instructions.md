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

### Content Routing

- ALWAYS place plan files in `docs/plans/active/` (in-progress) or `docs/plans/done/` (completed).
- ALWAYS place debt files in `docs/debt/open/` (active) or `docs/debt/resolved/` (resolved).
- NEVER embed plan content in non-plan files.
- NEVER embed debt content in non-debt files.

## Tools

- Lint: [mise run lint]
- Format: [mise run format]

## Workflow

- Read: Open FILE_MANIFEST entries and extract constraints relevant to the task.
- Plan: Define minimal edits and map each edit to a verified file path. Use `docs/templates/plan.md` for complex tasks.
- Path Verification Checkpoint: Before creating any plan or debt file, verify the output
  path is one of: `docs/plans/active/`, `docs/plans/done/`, `docs/debt/open/`,
  `docs/debt/resolved/`.
- Execute: Implement focused changes.
- Verify: Run `mise run lint` and `mise run format` after modifications.
- Evolve (Automatic): After completing Execute and Verify, evaluate whether ANY of the
  following conditions apply:
  (a) The task corrected behavior that resulted from a missing or ambiguous instruction.
  (b) The task introduced a design decision not yet captured in instructions or design docs.
  (c) The user explicitly requested an instruction update.
  If ANY condition is true, extract the missing constraint and execute Evolution Discipline
  BEFORE proceeding to Finalize.
- Finalize: Confirm outputs match requested scope. Before completing, verify:
  (1) All code edits during Execute were delegated to subagents.
  (2) If the task corrected behavior from a missing instruction, Evolve was executed.
  (3) Evolve output includes: Trigger, Missing Rule, New Rule, and Scope.
