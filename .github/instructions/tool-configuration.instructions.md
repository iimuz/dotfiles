---
applyTo: ".config/**"
---

# Tool Configuration

## Directory Convention

- Pattern: Each tool has its own directory: `.config/{tool}/`
- `{tool}-settings.sh` or `settings.sh` - Environment variables and shell integration
- Config files specific to the tool (config.toml, config.yml, etc.)

## Settings File Pattern

- Source: `.config/rc-settings.sh`
- Export environment variables needed by the tool
- Set up shell integration (eval, completions)
- Guard with tool availability check when appropriate

## Loading Order

- Note: The loading order in `rc-settings.sh` matters. Follow the existing sequence.
- Shell basics (bash settings, aliases, commands, paths, xdg)
- Homebrew
- mise
- Applications (aws-vault, bitwarden, fzf, git, gnupg, nvim, ssh, starship)
- Language environments (go, copilot, node, python, ruby)
- Path post-processing (must be last)
- Note: When adding a new tool, insert it in the appropriate section.

## Neovim Configuration

- Location: `.config/nvim/`
- Language: Lua
- Note: Follow existing plugin and keymap patterns.

## Conventions

- Use `export` for variables that child processes need
- Use shell-compatible syntax (no bash-only features in files sourced by both bash and zsh)
- Keep settings files minimal and focused on one tool
