# Setup script.

set -eu
set -o pipefail

# Create symlink if link does not exist.
function create_symlink() {
  local readonly src=$1
  local readonly dst=$2

  if [ -e $2 ]; then
    echo "already exist $2"
    return 0
  fi

  echo "symlink $1 to $2"
  mkdir -p $(dirname "$dst")
  ln -s $src $dst
}

# Install lazygit
# see: <https://github.com/jesseduffield/lazygit?tab=readme-ov-file#installation>
# ubuntu25.10以降は単純にaptでインストール可能になる。
function _install_lazygit() {
  local LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | \grep -Po '"tag_name": *"v\K[^"]*')
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
  local readonly filename="$1"

  if [[ "$SHELL" == *zsh* ]]; then
    # zshを利用しているので設定ファイルが異なる
    local readonly rcfile="$HOME/.zshrc"
  else
    # bashを想定している
    local readonly rcfile="$HOME/.bashrc"
  fi

  # if setting exits in rc file, do nothing.
  if grep $filename -l $rcfile >/dev/null 2>&1; then
    echo "already setting in $rcfile: $filename"
    return 0
  fi

  # Add file path.
  echo "set load setting in $rcfile: $filename"
  echo -e "if [ -f \"${filename}\" ]; then . \"${filename}\"; fi\n" >>$rcfile
}

# === 共通パスの設定
readonly SCRIPT_DIR=$(
  cd $(dirname ${BASH_SOURCE:-0})
  pwd
)
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
sudo apt-get install -y --no-install-recommends \
  gpg \
  pass

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
fi
# === github copoilot cli
if type copilot >/dev/null 2>&1; then
  create_symlink $SCRIPT_DIR/.config/copilot/agents $HOME/.config/.copilot/agents
  create_symlink $SCRIPT_DIR/.config/copilot/mcp-config.json $HOME/.config/.copilot/mcp-config.json
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
