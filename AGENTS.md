# AGENTS.md

## Repository Overview

Personal dotfiles repository for cross-platform shell configuration and tool setup.
Languages: Bash, Zsh, Lua, Python (hooks/tests), TOML. No Homebrew on non-macOS environments.

## Development Setup

Requires [mise](https://mise.jdx.dev/).

```bash
mise run setup # install all tools
```

## Commands

- Lint: `mise run lint`
- Format: `mise run format`
- Test: `mise run test`

Run `mise run format` and `mise run lint` after any modifications.

## Architecture

- `.config/` — Tool configurations organized by tool name (one subdirectory per tool)
- `.config/mise/` — Platform-specific mise tool configs
  (`config-mac.toml`, `config-linux.toml`, `config-codespaces.toml`, etc.)
- `.config/claude/` — Claude Code agent definitions, skills, hooks, and config
- `.config/copilot/` — Copilot agent definitions, skills, hooks, and config
- `.mise/` — Mise task definitions (shell scripts invoked by `mise run`)
- `docs/` — Design documents and ADRs
- `tests/` — Python test suite (primarily tests for hook scripts)
- `setup_*.sh` / `update_*.sh` — Platform-specific environment setup scripts at root

## Platform Setup Scripts

- Mac: `bash setup_mac.sh`
- Linux aarch64: `bash setup_aarch64.sh` / `bash update_aarch64.sh`
- Codespaces:`bash setup_codespaces.sh`
- WSL: `bash setup_wsl_ubuntu.sh`
- Termux: `bash setup_termux.sh`

## CI

The CI workflow (`.github/workflows/ci.yml`) only runs `mise run lint`
and sets `MISE_IGNORED_CONFIG_PATHS` to skip platform-specific configs
(mac, linux, colima, codespaces, termux variants) that are not available
in the CI environment.
