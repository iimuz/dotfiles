#!/usr/bin/env bash
# Setup script.

set -eu
set -o pipefail

# Install lazygit
# see: <https://github.com/jesseduffield/lazygit?tab=readme-ov-file#installation>
# ubuntu25.10以降は単純にaptでインストール可能になる。
function _install_lazygit() {
  local LAZYGIT_VERSION
  LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | \grep -Po '"tag_name": *"v\K[^"]*')
  curl -Lo lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/download/v${LAZYGIT_VERSION}/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"
  tar xf lazygit.tar.gz lazygit
  sudo install lazygit -D -t /usr/local/bin/
}

# Install neovim
# see: <https://github.com/neovim/neovim/blob/master/INSTALL.md>
function _install_neovim() {
  local BINARY=nvim-linux-x86_64.appimage

  curl -LO https://github.com/neovim/neovim/releases/latest/download/$BINARY
  chmod u+x $BINARY
  sudo install $BINARY -D -t /usr/local/bin/
  sudo ln -s /usr/local/bin/$BINARY /usr/local/bin/nvim
}

function _install_yq() {
  local VERSION=v4.47.1
  local BINARY=yq_linux_amd64

  wget https://github.com/mikefarah/yq/releases/download/${VERSION}/${BINARY}.tar.gz -O - | tar xz
  mv $BINARY yq
  sudo install yq -D -t /usr/local/bin/
}

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
# aptでインストール可能なコマンドはaptでインストールする
#
# - libreadline-dev: miseからluaをインストールする際に必要
sudo apt-get install -y --no-install-recommends \
  build-essential \
  fzf \
  gh \
  git-delta \
  jq \
  libreadline-dev \
  ripgrep \
  rsync \
  vifm \
  vim \
  tmux \
  unzip \
  zsh

# 各種設定ファイルの配置もしくは読み込み設定
set_bashrc "$CONFIG_PATH/rc-settings.sh"
# === docker
if ! type docker >/dev/null 2>&1; then
  curl -fsSL https://get.docker.com | sudo sh
  sudo usermod -aG docker "$(whoami)"
fi
# ===gh
if type gh >/dev/null 2>&1; then
  gh extension install dlvhdr/gh-dash
  create_symlink "$SCRIPT_DIR/.config/gh-dash/config.yml" "$HOME/.config/gh-dash/config.yml"
fi
# === git
if type git >/dev/null 2>&1; then
  create_symlink "$SCRIPT_DIR/.gitconfig" "$HOME/.gitconfig"
  create_symlink "$SCRIPT_DIR/.config/git/ignore" "$HOME/.config/git/ignore"
fi
# === lazygit
if ! type lazygit >/dev/null 2>&1; then _install_lazygit; fi
if type lazygit >/dev/null 2>&1; then
  create_symlink "$SCRIPT_DIR/.config/lazygit/config.yml" "$HOME/.config/lazygit/config.yml"
fi
# === [mise](https://github.com/jdx/mise)
if ! type mise >/dev/null 2>&1; then curl https://mise.run | sh; fi
if type mise >/dev/null 2>&1; then
  create_symlink "$SCRIPT_DIR/.config/mise/config-linux.toml" "$HOME/.config/mise/config.toml"
fi
# === neovim
if ! type nvim >/dev/null 2>&1; then _install_neovim; fi
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
# === yq
if ! type yq >/dev/null 2>&1; then _install_yq; fi
# === zsh
if type zsh >/dev/null 2>&1; then
  sudo chsh -s "$(which zsh)" "$(whoami)"
fi
