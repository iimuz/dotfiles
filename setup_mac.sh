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

# === Install [homebrew](https://brew.sh/index_ja)
# if ! type brew >/dev/null 2>&1; then
#   /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
# fi

# === Install softwaare
# homebrewを利用するための設定を追記して再読み込み
# set_bashrc "$CONFIG_PATH/homebrew/homebrew-bundle.sh"
# if [[ "$SHELL" == *zsh* ]]; then
#   # zshを利用しているので設定ファイルが異なる
#   echo "Use zsh"
#   source ~/.zshrc
# else
#   echo "Use bash"
#   # bashを想定している
#   source ~/.bashrc
# fi
# # homebrewを利用して各種ソフトウェアをインストール
# brew bundle

# 各種設定ファイルの配置もしくは読み込み設定
set_bashrc "$CONFIG_PATH/rc-settings.sh"

# === bash
if type bash >/dev/null 2>&1; then
  create_symlink "$SCRIPT_DIR/.inputrc" "$HOME/.inputrc"
fi

# === claude
if type claude >/dev/null 2>&1; then
  create_symlink "$SCRIPT_DIR/.config/claude/CLAUDE.md" "$HOME/.claude/CLAUDE.md"
  create_symlink "$SCRIPT_DIR/.config/claude/skills" "$HOME/.claude/skills"
  # settings.json は sandbox を on にした場合に symlink だと bubblewrap が起動できなくなるので hard link
  create_hardlink "$SCRIPT_DIR/.config/claude/settings.json" "$HOME/.claude/settings.json"
  create_symlink "$SCRIPT_DIR/.config/claude/hooks" "$HOME/.claude/hooks"
  create_symlink "$SCRIPT_DIR/.config/sandbox-runtime/.srt-settings.json" "$HOME/.srt-settings.json"

  # Setup MCP
  add_claude_mcp context-mode "context-mode"

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

  create_symlink "$SCRIPT_DIR/.config/claude/marketplace" "$HOME/.claude/marketplace"
  claude plugin marketplace add "$HOME/.claude/marketplace"
  claude plugin install "six-hats@iimuz-dotfiles"
  claude plugin install "scamper@iimuz-dotfiles"

  if type ccstatusline >/dev/null 2>&1; then
    create_symlink "$SCRIPT_DIR/.config/ccstatusline/settings.json" "$HOME/.config/ccstatusline/settings.json"
  fi
fi
# === gh
if type gh >/dev/null 2>&1; then
  gh extension install dlvhdr/gh-dash
  create_symlink "$SCRIPT_DIR/.config/gh-dash/config.yml" "$HOME/.config/gh-dash/config.yml"

  gh extension install kmtym1998/gh-prowl
fi
# === git
if type git >/dev/null 2>&1; then
  create_symlink "$SCRIPT_DIR/.gitconfig" "$HOME/.gitconfig"
  create_symlink "$SCRIPT_DIR/.config/git/ignore" "$HOME/.config/git/ignore"
  create_symlink "$SCRIPT_DIR/.config/git/credential-gh-helper" "$HOME/.local/bin/credential-gh-helper"
fi
# === ghostty
create_symlink "$SCRIPT_DIR/.config/ghostty/config" "$HOME/.config/ghostty/config"
# === lazygit
if type lazygit >/dev/null 2>&1; then
  create_symlink "$SCRIPT_DIR/.config/lazygit/config.yml" "$HOME/.config/lazygit/config.yml"
fi
# === mise
if type mise >/dev/null 2>&1; then
  create_symlink "$SCRIPT_DIR/.config/mise/config-mac.toml" "$HOME/.config/mise/config.toml"
fi
# === neovim
if type nvim >/dev/null 2>&1; then
  create_symlink "$SCRIPT_DIR/.config/nvim" "$HOME/.config/nvim"
  # create_symlink "$SCRIPT_DIR/.config/nvim/mcphub" "$HOME/.config/mcphub"
fi
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
# === copilot cli
if type copilot >/dev/null 2>&1; then
  # Copilot CLI
  create_symlink "$SCRIPT_DIR/.config/copilot/agents" "$HOME/.copilot/agents"
  create_symlink "$SCRIPT_DIR/.config/copilot/copilot-instructions.md" "$HOME/.copilot/copilot-instructions.md"
  create_symlink "$SCRIPT_DIR/.config/copilot/lsp-config.json" "$HOME/.copilot/lsp-config.json"
  create_symlink "$SCRIPT_DIR/.config/copilot/mcp-config.json" "$HOME/.copilot/mcp-config.json"
  create_symlink "$SCRIPT_DIR/.config/copilot/skills" "$HOME/.copilot/skills"
  create_symlink "$SCRIPT_DIR/.config/copilot/hooks" "$HOME/.copilot/hooks"
fi
