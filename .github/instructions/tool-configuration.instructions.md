---
applyTo: ".config/**"
---

# Tool Configuration

## Directory Convention

Each tool has its own directory at `.config/{tool}/` containing:

- Settings file: `{tool}-settings.sh` or `settings.sh` for environment variables and shell integration.
- Config files: Specific to the tool (`config.toml`, `config.yml`, etc.).

## Settings File Pattern

All tool settings are sourced from `.config/rc-settings.sh`.

- Export environment variables needed by the tool.
- Set up shell integration (eval, completions).
- Guard with tool availability check when appropriate.

## Loading Order

The loading order in `rc-settings.sh` matters. Follow the existing sequence. When adding a new tool, insert it in the appropriate section.

1. Shell basics (bash settings, aliases, commands, paths, xdg).
2. Homebrew.
3. mise.
4. Applications (aws-vault, bitwarden, fzf, git, gnupg, nvim, ssh, starship).
5. Language environments (go, copilot, node, python, ruby).
6. Path post-processing (must be last).

## Neovim Configuration

- Location: `.config/nvim/`.
- Language: Lua.
- Follow existing plugin and keymap patterns.

## Conventions

- Use `export` for variables that child processes need.
- Use shell-compatible syntax. Do not use bash-only features in files sourced by both bash and zsh.
- Keep settings files minimal and focused on one tool.
