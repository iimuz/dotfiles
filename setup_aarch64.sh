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

# Installが確認できていないツール
# - eza
# apt でインストールするとバージョンが古い場合があるので mise でツール類は管理する
sudo apt-get install -y --no-install-recommends \
  build-essential \
  rsync \
  vim \
  tmux \
  unzip \
  zsh
# プロセス監視 (mise になく github で pre-build binary も配布していない)
sudo apt-get install -y --no-install-recommends htop
# ssh agent の管理
sudo apt-get install -y --no-install-recommends keychain
# password manager
sudo apt-get install -y --no-install-recommends gnupg pass
# miseからluaをインストールする際に必要
sudo apt-get install -y --no-install-recommends libreadline-dev
# mise から tree sitter cli の cargo build でパッケージが不足するため
sudo apt-get install -y --no-install-recommends libclang-dev
# claude code で sandbox 機能を利用するための前提条件
sudo apt-get install -y --no-install-recommends bubblewrap socat
# qmd で cpu only の環境で vulkan でビルドしようとして失敗するのでビルドだけ成功させる
sudo apt-get install -y --no-install-recommends libvulkan-dev glslc vulkan-tools

# 各種設定ファイルの配置もしくは読み込み設定
set_bashrc "$CONFIG_PATH/rc-settings.sh"

# === [mise](https://github.com/jdx/mise)
if ! type mise >/dev/null 2>&1; then curl https://mise.run | sh; fi
if type mise >/dev/null 2>&1; then
  create_symlink "$SCRIPT_DIR/.config/mise/config-linux.toml" "$HOME/.config/mise/config.toml"
fi

# === claude
if type claude >/dev/null 2>&1; then
  create_symlink "$SCRIPT_DIR/.config/claude/CLAUDE.md" "$HOME/.claude/CLAUDE.md"
  create_symlink "$SCRIPT_DIR/.config/claude/skills" "$HOME/.claude/skills"
  # settings.json は sandbox を on にした場合に symlink だと bubblewrap が起動できなくなるので hard link
  create_hardlink "$SCRIPT_DIR/.config/claude/settings.json" "$HOME/.claude/settings.json"
  create_symlink "$SCRIPT_DIR/.config/sandbox-runtime/.srt-settings.json" "$HOME/.srt-settings.json"

  # Setup MCP
  add_claude_mcp context-mode sh -c "mkdir -p /tmp/claude && exec srt context-mode"

  # Setup Plugins
  claude plugins install --scope user gopls-lsp
  claude plugins install --scope user lua-lsp
  claude plugins install --scope user pyright-lsp
  claude plugins install --scope user rust-analyzer-lsp
  claude plugins install --scope user typescript-lsp
  claude plugins install --scope user superpowers@claude-plugins-official

  claude plugin marketplace add "awslabs/agent-plugins"
  claude plugin install "deploy-on-aws@agent-plugins-for-aws"
  claude plugin disable "deploy-on-aws@agent-plugins-for-aws"

  if type ccstatusline >/dev/null 2>&1; then
    create_symlink "$SCRIPT_DIR/.config/ccstatusline/settings.json" "$HOME/.config/ccstatusline/settings.json"
  fi
fi
# === docker
if ! type docker >/dev/null 2>&1; then
  curl -fsSL https://get.docker.com | sudo sh
  sudo usermod -aG docker "$(whoami)"
fi
# === gh
if type gh >/dev/null 2>&1; then
  gh extension install dlvhdr/gh-dash
  create_symlink "$SCRIPT_DIR/.config/gh-dash/config.yml" "$HOME/.config/gh-dash/config.yml"
fi
# === git
if type git >/dev/null 2>&1; then
  create_symlink "$SCRIPT_DIR/.gitconfig" "$HOME/.gitconfig"
  create_symlink "$SCRIPT_DIR/.config/git/ignore" "$HOME/.config/git/ignore"
  create_symlink "$SCRIPT_DIR/.config/git/credential-gh-helper" "$HOME/.local/bin/credential-gh-helper"
fi
# === OpenCode
if type opencode >/dev/null 2>&1; then
  create_symlink "$SCRIPT_DIR/.config/opencode/agents" "$HOME/.config/opencode/agents"
  create_symlink "$SCRIPT_DIR/.config/opencode/AGENTS.md" "$HOME/.config/opencode/AGENTS.md"
  create_symlink "$SCRIPT_DIR/.config/opencode/opencode.jsonc" "$HOME/.config/opencode/opencode.jsonc"
  create_symlink "$SCRIPT_DIR/.config/opencode/skills" "$HOME/.config/opencode/skills"
  create_symlink "$SCRIPT_DIR/.config/opencode/tui.jsonc" "$HOME/.config/opencode/tui.jsonc"
fi
# === gpg
if type gpg >/dev/null 2>&1; then
  create_symlink "$SCRIPT_DIR/.config/gnupg/gpg-agent.conf" "$HOME/.gnupg/gpg-agent.conf"
fi
# === lazygit
if type lazygit >/dev/null 2>&1; then
  create_symlink "$SCRIPT_DIR/.config/lazygit/config.yml" "$HOME/.config/lazygit/config.yml"
fi
# === neovim
if type nvim >/dev/null 2>&1; then
  create_symlink "$SCRIPT_DIR/.config/nvim" "$HOME/.config/nvim"
fi
# === starship
if ! type starship >/dev/null 2>&1; then curl -sS https://starship.rs/install.sh | sudo sh; fi
# === tailscale
# see: <https://tailscale.com/download/linux>
if ! type tailscale >/dev/null 2>&1; then curl -fsSL https://tailscale.com/install.sh | sh; fi
# === tmux
if type tmux >/dev/null 2>&1; then
  if [ ! -d "$HOME/.tmux/plugins/tpm" ]; then
    git clone "https://github.com/tmux-plugins/tpm" "$HOME/.tmux/plugins/tpm"
  fi
  create_symlink "$SCRIPT_DIR/.tmux.conf" "$HOME/.tmux.conf"
  create_symlink "$SCRIPT_DIR/.config/tmux/new-window-fzf.sh" "$HOME/.config/tmux/new-window-fzf.sh"
fi
# === vifm
if type vifm >/dev/null 2>&1; then
  create_symlink "$SCRIPT_DIR/.config/vifm/vifmrc" "$HOME/.config/vifm/vifmrc"
fi
# === vim
if type vim >/dev/null 2>&1; then
  create_symlink "$SCRIPT_DIR/.config/vim/init.vim" "$HOME/.vimrc"
  create_symlink "$SCRIPT_DIR/.config/vim" "$HOME/.config/vim"
fi
# === zsh
if type zsh >/dev/null 2>&1; then
  sudo chsh -s "$(which zsh)" "$(whoami)"
fi
