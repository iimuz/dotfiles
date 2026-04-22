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
# apt でインストールするとバージョンが古い場合があるので mise でツール類は管理する
sudo apt-get update
sudo apt-get install -y --no-install-recommends \
  build-essential \
  rsync \
  vifm \
  vim \
  tmux \
  unzip \
  zsh
# miseからluaをインストールする際に必要
sudo apt-get install -y --no-install-recommends libreadline-dev
# mise から tree sitter cli の cargo build でパッケージが不足するため
sudo apt-get install -y --no-install-recommends libclang-dev
# rust で build するときにメモリが大量に必要なので少なくできる構成を追加
sudo apt-get install -y --no-install-recommends mold

# 各種設定ファイルの配置もしくは読み込み設定
set_bashrc "$CONFIG_PATH/rc-settings.sh"

# === [mise](https://github.com/jdx/mise)
if ! type mise >/dev/null 2>&1; then curl https://mise.run | sh; fi
if type mise >/dev/null 2>&1; then
  create_symlink "$SCRIPT_DIR/.config/mise/config-colima.toml" "$HOME/.config/mise/config.toml"
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
# === github copilot cli
if type copilot >/dev/null 2>&1; then
  create_symlink "$SCRIPT_DIR/.config/copilot/agents" "$HOME/.copilot/agents"
  create_symlink "$SCRIPT_DIR/.config/copilot/copilot-instructions.md" "$HOME/.copilot/copilot-instructions.md"
  create_symlink "$SCRIPT_DIR/.config/copilot/lsp-config.json" "$HOME/.copilot/lsp-config.json"
  create_symlink "$SCRIPT_DIR/.config/copilot/mcp-config.json" "$HOME/.copilot/mcp-config.json"
  create_symlink "$SCRIPT_DIR/.config/copilot/skills" "$HOME/.copilot/skills"
  create_symlink "$SCRIPT_DIR/.config/copilot/hooks" "$HOME/.copilot/hooks"

  # Copilot tools
  if type rtk >/dev/null 2>&1; then
    create_symlink "$SCRIPT_DIR/.config/rtk/config.toml" "$HOME/.config/rtk/config.toml"
  fi
fi
# === lazygit
if type lazygit >/dev/null 2>&1; then
  create_symlink "$SCRIPT_DIR/.config/lazygit/config.yml" "$HOME/.config/lazygit/config.yml"
fi
# === neovim
if type nvim >/dev/null 2>&1; then
  create_symlink "$SCRIPT_DIR/.config/nvim" "$HOME/.config/nvim"
fi
# === rust
if type cargo >/dev/null 2>&1; then
  create_symlink "$SCRIPT_DIR/.config/rust/config.toml" "$HOME/.cargo/config.toml"
fi
# === starship
if ! type starship >/dev/null 2>&1; then curl -sS https://starship.rs/install.sh | sudo sh; fi
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
