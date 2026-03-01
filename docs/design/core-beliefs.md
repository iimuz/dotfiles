# Core Beliefs

## Project Identity

- Name: dotfiles
- Type: Cross-platform shell configuration and tool setup
- Language: Bash, Zsh, Lua

## Tech Stack (Constraints)

- Runtime: Bash 5+ / Zsh 5+
- Package Manager macOS: Homebrew
- Package Manager Linux: apt, pkg (Termux)
- Version Manager: mise
- Config Format: Shell scripts, TOML, YAML, Lua
- Linting: shellcheck, markdownlint
- Formatting: shfmt, prettier

## Routing

- Context and Constraints: `docs/design/core-beliefs.md`
- Design Documents: `docs/design/`
- Active Tasks: `docs/plans/active/`
- Tech Debt and State: `docs/debt/`
- Document Templates: `docs/templates/`

## Architecture Principles

- Pattern: Symlink-based deployment
- Config Bootstrap: Central via `.config/rc-settings.sh`
- Loading Order: shell → homebrew → applications → language environments → path finalization
- Platform Isolation: Platform-specific scripts with shared helper functions

## Coding Style (Non-Linter Rules)

- Comments: Explain 'Why', not 'What'.
- Naming: snake_case for shell functions (create_symlink, set_bashrc).
- Tool Detection: Check availability with `type command > /dev/null 2>&1` before configuration.
- State: Keep local unless shared.

## Anti Patterns (Forbidden)

- No hardcoded absolute paths (use $HOME).
- No duplicate entries in shell config (check with grep before appending).
- No tool configuration without availability check.
- No Homebrew on non-macOS environments.
