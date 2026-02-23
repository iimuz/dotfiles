# CORE_BELIEFS

## PROJECT_IDENTITY

- Name: dotfiles
- Type: Cross-platform shell configuration and tool setup
- Language: Bash, Zsh, Lua

## TECH_STACK (Constraints)

- Runtime: Bash 5+ / Zsh 5+
- PackageManagerMacos: Homebrew
- PackageManagerLinux: apt, pkg (Termux)
- VersionManager: mise
- ConfigFormat: Shell scripts, TOML, YAML, Lua
- Linting: shellcheck, markdownlint
- Formatting: shfmt, prettier

## ROUTING

- ContextAndConstraints: `docs/design/core-beliefs.md`
- DesignDocuments: `docs/design/`
- ActiveTasks: `docs/plans/active/`
- TechDebtAndState: `docs/debt/`
- DocumentTemplates: `docs/templates/`

## ARCHITECTURE_PRINCIPLES

- Pattern: Symlink-based deployment
- ConfigBootstrap: Central via `.config/rc-settings.sh`
- LoadingOrder: shell → homebrew → applications → language environments → path finalization
- PlatformIsolation: Platform-specific scripts with shared helper functions

## CODING_STYLE (Non-Linter Rules)

- Comments: Explain 'Why', not 'What'.
- Naming: snake_case for shell functions (create_symlink, set_bashrc).
- ToolDetection: Check availability with `type command > /dev/null 2>&1` before configuration.
- State: Keep local unless shared.

## ANTI_PATTERNS (Forbidden)

- No hardcoded absolute paths (use $HOME).
- No duplicate entries in shell config (check with grep before appending).
- No tool configuration without availability check.
- No Homebrew on non-macOS environments.
