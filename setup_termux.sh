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

# Installが確認できていないツール
# - eza
# pkgでインストール可能なコマンドはpkgでインストールする
#
# - build-essential: build package for neovim
# - libreadline-dev: miseからluaをインストールする際に必要
pkg install -y \
  build-essential \
  fzf \
  gh \
  git-delta \
  jq \
  lazygit \
  neovim \
  ripgrep \
  rsync \
  vifm \
  vim \
  tmux \
  yq

# 各種設定ファイルの配置もしくは読み込み設定
set_bashrc "$CONFIG_PATH/rc-settings.sh"

# === git
if type git >/dev/null 2>&1; then
  create_symlink "$SCRIPT_DIR/.gitconfig" "$HOME/.gitconfig"
  create_symlink "$SCRIPT_DIR/.config/git/ignore" "$HOME/.config/git/ignore"
fi
# === lazygit
if type lazygit >/dev/null 2>&1; then
  create_symlink "$SCRIPT_DIR/.config/lazygit/config.yml" "$HOME/.config/lazygit/config.yml"
fi
# === neovim
if type nvim >/dev/null 2>&1; then
  create_symlink "$SCRIPT_DIR/.config/nvim" "$HOME/.config/nvim"
fi
# === tmux
if type tmux >/dev/null 2>&1; then
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
