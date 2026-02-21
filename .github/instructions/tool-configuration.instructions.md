---
applyTo: ".config/**"
---

# Tool Configuration

## Directory Convention

Each tool has its own directory: `.config/{tool}/`

Typical contents:

- `{tool}-settings.sh` or `settings.sh` - Environment variables and shell integration
- Config files specific to the tool (config.toml, config.yml, etc.)

## Settings File Pattern

Settings files are sourced by `.config/rc-settings.sh`. They should:

- Export environment variables needed by the tool
- Set up shell integration (eval, completions)
- Guard with tool availability check when appropriate

## Loading Order

The loading order in `rc-settings.sh` matters. Follow the existing sequence:

1. Shell basics (bash settings, aliases, commands, paths, xdg)
2. Homebrew
3. mise
4. Applications (aws-vault, bitwarden, fzf, git, gnupg, nvim, ssh, starship)
5. Language environments (go, copilot, node, python, ruby)
6. Path post-processing (must be last)

When adding a new tool, insert it in the appropriate section.

## Neovim Configuration

Neovim config lives in `.config/nvim/` and uses Lua. Follow existing plugin and keymap patterns.

## Conventions

- Use `export` for variables that child processes need
- Use shell-compatible syntax (no bash-only features in files sourced by both bash and zsh)
- Keep settings files minimal and focused on one tool
