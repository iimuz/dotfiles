# AGENTS.md

## Repository Overview

Personal dotfiles repository for cross-platform shell configuration and tool setup.
Languages: Bash, Zsh, Lua, Python (hooks/tests), TOML. No Homebrew on non-macOS environments.

## Development Setup

Requires mise.

```bash
mise run setup # install all tools
```

## Commands

- Lint: `mise run lint`
- Format: `mise run format`
- Test: `mise run test` (runs pytest and bats)

Run `mise run format` and `mise run lint` after any modifications.

## Architecture

- `.config/`: Tool configurations organized by tool name (one subdirectory per tool)
  - `.config/mise/`: Platform-specific mise tool configs; each `setup_*.sh` symlinks the
    matching `config-{platform}.toml` to `~/.config/mise/config.toml`
  - `.config/claude/`: Claude Code user settings managed as dotfiles (CLAUDE.md, skills/,
    settings.json, runcat-statusline.py); distinct from `.claude/` (runtime directory used by
    the Claude Code process). `runcat-statusline.py` is the statusLine command: it relays
    ccstatusline for the terminal and writes a RunCat Neo custom-metrics snapshot
    (`~/.claude/runcat-usage.json`: 5h / 7d rate limits and the current-month ccusage cost).
    Register that file in RunCat Neo (Settings -> Metrics -> Custom Metrics; macOS only).
  - `.config/copilot/`: Copilot agent definitions, skills, hooks, and config
  - Other tool configs follow the same one-directory-per-tool pattern
- `.claude/`: Claude Code runtime directory (settings.json, agents, commands/)
- `mise.toml`: Tool versions and inline task definitions (`setup`, `format`,
  `lint`, `test`); tasks that need a real script go in `scripts/` and are
  referenced from `mise.toml` (none currently)
- `docs/`: Design documents and ADRs
- `lib/`: Shared shell libraries sourced by setup scripts (e.g. `setup-common.sh`)
- `tests/`: Test suites — pytest (hook scripts, repository integrity) and bats
  (shell helper functions in `lib/`); both run via `mise run test`
- `lefthook.yml`: Pre-commit hook definition (runs format → lint + test automatically)
- `setup_*.sh` / `update_*.sh`: Platform-specific environment setup scripts at root

## Platform Setup Scripts

Platform-specific setup scripts follow the `setup_*.sh` pattern; update scripts follow `update_*.sh`.

## CI

The CI workflow (`.github/workflows/ci.yml`) runs `mise run lint` and `mise run test`
as parallel jobs.
Platform-specific mise configs are loaded only via symlinks created by `setup_*.sh` scripts,
so they are not present in the CI environment.
