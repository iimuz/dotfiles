# Copilot Instructions

## Project Context

- Type: Cross-platform shell configuration and tool setup.
- Languages: Bash, Zsh, Lua.
- Runtime: Bash 5+ / Zsh 5+.
- No Homebrew on non-macOS environments.

## File Manifest

- Setup Scripts: `setup_*.sh`, `update_*.sh`
- Configurations: `.config/`
- Mise Settings: `.mise/`
- Documents: `docs/`
  - Design: `docs/design/`
  - Planning: `docs/planning.md`
  - Templates: `docs/templates/`

## Directives

- Apply the smallest viable change set for the requested task.
- Verify file existence before reading or referencing files.
- When creating new files, place them according to established project
  directory conventions. Do not invent unsolicited directory structures.
- Use only available `mise run` tasks listed in Tools section.
- Run relevant existing checks after modifications.

## Tools

- Lint: `mise run lint`
- Format: `mise run format`

## Workflow

1. Read: Open file manifest entries and extract constraints relevant to the task.
2. Plan: Determine the minimal set of changes needed. If the user provided a
   tagged plan file, use that file.
3. Execute: Implement focused changes.
4. Verify: Run `mise run lint` and `mise run format` after modifications.
