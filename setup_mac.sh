#!/usr/bin/env bash
# Setup script.

set -eu
set -o pipefail

# Create symlink if link does not exist.
function create_symlink() {
  local -r src=$1
  local -r dst=$2

  if [ -e "$dst" ]; then
    echo "already exist $dst"
    return 0
  fi

  echo "symlink $src to $dst"
  mkdir -p "$(dirname "$dst")"
  ln -s "$src" "$dst"
}

# Add loading file in .bashrc or .zshrc.
function set_bashrc() {
  local -r filename="$1"

  if [[ "$SHELL" == *zsh* ]]; then
    # zshを利用しているので設定ファイルが異なる
    local -r rcfile="$HOME/.zshrc"
  else
    # bashを想定している
    local -r rcfile="$HOME/.bashrc"
  fi

  # if setting exits in rc file, do nothing.
  if grep -qF -- "$filename" "$rcfile" >/dev/null 2>&1; then
    echo "already setting in $rcfile: $filename"
    return 0
  fi

  # Add file path.
  echo "set load setting in $rcfile: $filename"
  echo -e "if [ -f \"${filename}\" ]; then . \"${filename}\"; fi\n" >>"$rcfile"
}

# === 共通パスの設定
SCRIPT_DIR=
SCRIPT_DIR=$(
  cd "$(dirname "${BASH_SOURCE:-0}")"
  pwd
)
readonly SCRIPT_DIR
readonly CONFIG_PATH=$SCRIPT_DIR/.config

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
  create_symlink "$SCRIPT_DIR/.config/nvim/mcphub" "$HOME/.config/mcphub"
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
fi
