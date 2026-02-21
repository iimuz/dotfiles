# CORE_BELIEFS

## PROJECT_IDENTITY

- Name: dotfiles
- Type: Cross-platform shell configuration and tool setup
- Language: Bash, Zsh, Lua

## TECH_STACK (Constraints)

- Runtime: Bash 5+ / Zsh 5+
- Package_Manager_macOS: Homebrew
- Package_Manager_Linux: apt, pkg (Termux)
- Version_Manager: mise
- Config_Format: Shell scripts, TOML, YAML, Lua
- Linting: shellcheck, markdownlint
- Formatting: shfmt, prettier

## ROUTING

- Context & Constraints: `docs/design/core-beliefs.md`
- Design Documents: `docs/design/`
- Active Tasks: `docs/plans/active/`
- Tech Debt & State: `docs/debt/`
- Document Templates: `docs/templates/`

## ARCHITECTURE_PRINCIPLES

- Pattern: Symlink-based deployment
- Config_Bootstrap: Central via `.config/rc-settings.sh`
- Loading_Order: shell → homebrew → applications → language environments → path finalization
- Platform_Isolation: Platform-specific scripts with shared helper functions

## CODING_STYLE (Non-Linter Rules)

- Comments: Explain 'Why', not 'What'.
- Naming: snake_case for shell functions (create_symlink, set_bashrc).
- Tool_Detection: Check availability with `type command > /dev/null 2>&1` before configuration.
- State: Keep local unless shared.

## ANTI_PATTERNS (Forbidden)

- No hardcoded absolute paths (use $HOME).
- No duplicate entries in shell config (check with grep before appending).
- No tool configuration without availability check.
- No Homebrew on non-macOS environments.
