#!/usr/bin/env bash
# Setup script.

set -eu
set -o pipefail

# === 共通パスの設定
SCRIPT_DIR=
SCRIPT_DIR=$(
  cd "$(dirname "${BASH_SOURCE:-0}")"
  pwd
)
readonly SCRIPT_DIR
readonly CONFIG_PATH=$SCRIPT_DIR/.config

# Load shared helper functions
. "$SCRIPT_DIR/lib/setup-common.sh"

# 各種設定ファイルの配置もしくは読み込み設定
set_bashrc "$CONFIG_PATH/rc-settings.sh"
# === gh
if type gh >/dev/null 2>&1; then
  create_symlink "$SCRIPT_DIR/.config/gh-dash/config.yml" "$HOME/.config/gh-dash/config.yml"
fi
# === git
if type git >/dev/null 2>&1; then
  create_symlink "$SCRIPT_DIR/.gitconfig" "$HOME/.gitconfig"
  create_symlink "$SCRIPT_DIR/.config/git/ignore" "$HOME/.config/git/ignore"
  create_symlink "$SCRIPT_DIR/.config/git/credential-gh-helper" "$HOME/.local/bin/credential-gh-helper"
fi
# === github copilot cli
if type copilot >/dev/null 2>&1; then
  create_symlink "$SCRIPT_DIR/.config/copilot/agents" "$HOME/.copilot/agents"
  create_symlink "$SCRIPT_DIR/.config/copilot/skills" "$HOME/.copilot/skills"
  create_symlink "$SCRIPT_DIR/.config/copilot/hooks" "$HOME/.copilot/hooks"
  create_symlink "$SCRIPT_DIR/.config/copilot/mcp-config.json" "$HOME/.copilot/mcp-config.json"
fi
# === lazygit
if type lazygit >/dev/null 2>&1; then
  create_symlink "$SCRIPT_DIR/.config/lazygit/config.yml" "$HOME/.config/lazygit/config.yml"
fi
# === [mise](https://github.com/jdx/mise)
if type mise >/dev/null 2>&1; then
  create_symlink "$SCRIPT_DIR/.config/mise/config-codespaces.toml" "$HOME/.config/mise/config.toml"
fi
# === neovim
if type nvim >/dev/null 2>&1; then
  create_symlink "$SCRIPT_DIR/.config/nvim" "$HOME/.config/nvim"
fi
# === starship
if ! type starship >/dev/null 2>&1; then curl -sS https://starship.rs/install.sh | sudo sh; fi
# === tmux
if type tmux >/dev/null 2>&1; then
  create_symlink "$SCRIPT_DIR/.tmux.conf" "$HOME/.tmux.conf"
  create_symlink "$SCRIPT_DIR/.config/tmux/new-window-fzf.sh" "$HOME/.config/tmux/new-window-fzf.sh"
fi
# === vifm
if type vifm >/dev/null 2>&1; then
  create_symlink "$SCRIPT_DIR/.config/vifm/vifmrc" "$HOME/.config/vifm/vifmrc"
fi
