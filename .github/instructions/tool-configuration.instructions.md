---
applyTo: ".config/**"
---

# Tool Configuration

## Directory Convention

- Pattern: Each tool has its own directory `.config/{tool}/`.
- Settings File: `{tool}-settings.sh` or `settings.sh` - Environment variables and shell integration.
- Config Files: Specific to the tool (config.toml, config.yml, etc.).

## Settings File Pattern

- Source: `.config/rc-settings.sh`.
- Requirement: Export environment variables needed by the tool.
- Requirement: Set up shell integration (eval, completions).
- Requirement: Guard with tool availability check when appropriate.

## Loading Order

- Constraint: The loading order in `rc-settings.sh` matters. Follow the existing sequence.
- Order-1: Shell basics (bash settings, aliases, commands, paths, xdg).
- Order-2: Homebrew.
- Order-3: mise.
- Order-4: Applications (aws-vault, bitwarden, fzf, git, gnupg, nvim, ssh, starship).
- Order-5: Language environments (go, copilot, node, python, ruby).
- Order-6: Path post-processing (must be last).
- Note: When adding a new tool, insert it in the appropriate section.

## Neovim Configuration

- Location: `.config/nvim/`.
- Language: Lua.
- Pattern: Follow existing plugin and keymap patterns.

## Conventions

- Variable Scope: Use `export` for variables that child processes need.
- Shell Compatibility: Use shell-compatible syntax (no bash-only features in files sourced by both bash and zsh).
- File Scope: Keep settings files minimal and focused on one tool.
