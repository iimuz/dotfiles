# Setup script.

set -eu
set -o pipefail

# Create symlink if link does not exist.
function create_symlink() {
  local -r SRC=$1
  local -r DST=$2

  if [ -e "$DST" ]; then
    echo "already exist $DST"
    return 0
  fi

  echo "symlink $SRC to $DST"
  mkdir -p "$(dirname "$DST")"
  ln -s "$SRC" "$DST"
}

# Install lazygit
# see: <https://github.com/jesseduffield/lazygit?tab=readme-ov-file#installation>
# ubuntu25.10以降は単純にaptでインストール可能になる。
function _install_lazygit() {
  local LAZYGIT_VERSION=
  LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | \grep -Po '"tag_name": *"v\K[^"]*')
  readonly LAZYGIT_VERSION

  curl -Lo lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/download/v${LAZYGIT_VERSION}/lazygit_${LAZYGIT_VERSION}_Linux_arm64.tar.gz"
  tar xf lazygit.tar.gz lazygit
  sudo install lazygit -D -t /usr/local/bin/
}

# Install neovim
# see: <https://github.com/neovim/neovim/blob/master/INSTALL.md>
function _install_neovim() {
  local BINARY=nvim-linux-arm64.appimage

  curl -LO https://github.com/neovim/neovim/releases/latest/download/$BINARY
  chmod u+x $BINARY
  sudo install $BINARY -D -t /usr/local/bin/
  sudo ln -s /usr/local/bin/$BINARY /usr/local/bin/nvim
}

function _install_yq() {
  local VERSION=v4.47.1
  local BINARY=yq_linux_arm64

  wget https://github.com/mikefarah/yq/releases/download/${VERSION}/${BINARY}.tar.gz -O - | tar xz
  mv $BINARY yq
  sudo install yq -D -t /usr/local/bin/
}

# Add loading file in .bashrc or .zshrc.
function set_bashrc() {
  local -r FILENAME="$1"

  if [[ "$SHELL" == *zsh* ]]; then
    # zshを利用しているので設定ファイルが異なる
    local -r RCFILE="$HOME/.zshrc"
  else
    # bashを想定している
    local -r RCFILE="$HOME/.bashrc"
  fi

  # if setting exits in rc file, do nothing.
  if grep "$FILENAME" -l "$RCFILE" >/dev/null 2>&1; then
    echo "already setting in $RCFILE: $FILENAME"
    return 0
  fi

  # Add file path.
  echo "set load setting in $RCFILE: $FILENAME"
  echo -e "if [ -f \"${FILENAME}\" ]; then . \"${FILENAME}\"; fi\n" >>"$RCFILE"
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
# ssh agent の管理
sudo apt-get install -y --no-install-recommends keychain
# password manager
sudo apt-get install -y --no-install-recommends gnupg pass

# 各種設定ファイルの配置もしくは読み込み設定
set_bashrc $CONFIG_PATH/rc-settings.sh
# === claude
if type claude >/dev/null 2>&1; then
  create_symlink $SCRIPT_DIR/.config/claude/agents $HOME/.claude/agents
  create_symlink $SCRIPT_DIR/.config/claude/commands $HOME/.claude/commands
  create_symlink $SCRIPT_DIR/.config/claude/settings.json $HOME/.claude/settings.json
  create_symlink $SCRIPT_DIR/.config/claude/CLAUDE.md $HOME/.claude/CLAUDE.md
fi
# === docker
if ! type docker >/dev/null 2>&1; then
  curl -fsSL https://get.docker.com | sudo sh
  sudo usermod -aG docker $(whoami)
fi
# ===gh
if type gh >/dev/null 2>&1; then
  gh extension install dlvhdr/gh-dash
  create_symlink $SCRIPT_DIR/.config/gh-dash/config.yml $HOME/.config/gh-dash/config.yml
fi
# === git
if type git >/dev/null 2>&1; then
  create_symlink $SCRIPT_DIR/.gitconfig $HOME/.gitconfig
  create_symlink $SCRIPT_DIR/.config/git/ignore $HOME/.config/git/ignore
  create_symlink $SCRIPT_DIR/.config/git/credential-gh-helper $HOME/.local/bin/credential-gh-helper
fi
# === github copoilot cli
if type copilot >/dev/null 2>&1; then
  create_symlink $SCRIPT_DIR/.config/copilot/agents $HOME/.config/.copilot/agents
  create_symlink $SCRIPT_DIR/.config/copilot/mcp-config.json $HOME/.config/.copilot/mcp-config.json
fi
# === gpg
if type gpg >/dev/null 2>&1; then
  create_symlink $SCRIPT_DIR/.config/gnupg/gpg-agent.conf $HOME/.gnupg/gpg-agent.conf
fi
# === lazygit
if ! type lazygit >/dev/null 2>&1; then _install_lazygit; fi
if type lazygit >/dev/null 2>&1; then
  create_symlink $SCRIPT_DIR/.config/lazygit/config.yml $HOME/.config/lazygit/config.yml
fi
# === [mise](https://github.com/jdx/mise)
if ! type mise >/dev/null 2>&1; then curl https://mise.run | sh; fi
if type mise >/dev/null 2>&1; then
  create_symlink $SCRIPT_DIR/.config/mise/config.toml $HOME/.config/mise/config.toml
fi
# === neovim
if ! type nvim >/dev/null 2>&1; then _install_neovim; fi
if type nvim >/dev/null 2>&1; then
  create_symlink $SCRIPT_DIR/.config/nvim $HOME/.config/nvim
fi
# === starship
if ! type starship >/dev/null 2>&1; then curl -sS https://starship.rs/install.sh | sudo sh; fi
# === tailscale
# see: <https://tailscale.com/download/linux>
if ! type tailscale >/dev/null 2>&1; then curl -fsSL https://tailscale.com/install.sh | sh; fi
# === tmux
if type tmux >/dev/null 2>&1; then
  create_symlink $SCRIPT_DIR/.tmux.conf $HOME/.tmux.conf
fi
# === vifm
if type vifm >/dev/null 2>&1; then
  create_symlink $SCRIPT_DIR/.config/vifm/vifmrc $HOME/.config/vifm/vifmrc
fi
# === vim
if type vim >/dev/null 2>&1; then
  create_symlink $SCRIPT_DIR/.config/vim/init.vim $HOME/.vimrc
  create_symlink $SCRIPT_DIR/.config/vim $HOME/.config/vim
fi
# === yq
if ! type yq >/dev/null 2>&1; then _install_yq; fi
# === zsh
if type zsh >/dev/null 2>&1; then
  sudo chsh -s $(which zsh) $(whoami)
fi
