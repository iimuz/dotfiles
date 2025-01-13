# Setup script.

set -eu

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

# install cica
# See: <https://github.com/miiton/Cica>
function _install_cica() {
  local VERSION=v5.0.3
  curl -L -O https://github.com/miiton/Cica/releases/download/$VERSION/Cica_${VERSION}.zip
  unzip Cica_${VERSION}.zip 
  sudo mkdir  /usr/share/fonts/truetype/cica
  sudo cp *.ttf /usr/share/fonts/truetype/cica/
  sudo fc-cache -vf
}

# Install lazygit
function _install_lazygit() {
  local LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | \grep -Po '"tag_name": *"v\K[^"]*')
  curl -Lo lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/download/v${LAZYGIT_VERSION}/lazygit_${LAZYGIT_VERSION}_Linux_arm64.tar.gz"
  tar xf lazygit.tar.gz lazygit
  sudo install lazygit -D -t /usr/local/bin/
}

function _install_yq() {
  local VERSION=v4.44.6
  local BINARY=yq_linux_arm64

  wget https://github.com/mikefarah/yq/releases/download/${VERSION}/${BINARY}.tar.gz -O - | tar xz
  sudo install ${BINARY} -D -t /usr/local/bin/yq
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
  if grep $filename -l $rcfile > /dev/null 2>&1; then
    echo "already setting in $rcfile: $filename"
    return 0
  fi

  # Add file path.
  echo "set load setting in $rcfile: $filename"
  echo -e "if [ -f \"${filename}\" ]; then . \"${filename}\"; fi\n" >> $rcfile
}

# === 共通パスの設定
readonly SCRIPT_DIR=$(cd $(dirname ${BASH_SOURCE:-0}); pwd)
readonly CONFIG_PATH=$SCRIPT_DIR/.config

# Installが確認できていないツール
# - eza
# aptでインストール可能なコマンドはaptでインストールする
sudo apt-get install -y --no-install-recommends \
  jq \
  ripgrep \
  rsync

# 各種設定ファイルの配置もしくは読み込み設定
set_bashrc $CONFIG_PATH/rc-settings.sh
# === bash
if type alacritty > /dev/null 2>&1; then
  mkdir -p $HOME/.config/alacritty
  create_symlink $SCRIPT_DIR/.config/alacritty/alacritty.toml $HOME/.config/alacritty/alacritty.toml
fi
# === bash
if [ $(fc-list | grep -i cica | wc -l) == 0 ]; then _install_cica; fi
# === git
if type git > /dev/null 2>&1; then
  create_symlink $SCRIPT_DIR/.gitconfig $HOME/.gitconfig
  create_symlink $SCRIPT_DIR/.config/git/ignore $HOME/.config/git/ignore
fi
# === lazygit
if ! type lazygit > /dev/null 2>&1; then _install_lazygit; fi
if type lazygit > /dev/null 2>&1; then
  create_symlink $SCRIPT_DIR/.config/lazygit/config.yml $HOME/.config/lazygit/config.yml
fi
# === [mise](https/;/github.cojm/dx/mise)
if ! type mise > /dev/null 2>&1; then curl https://mise.run | sh; fi
# === neovim
if type nvim > /dev/null 2>&1; then
  create_symlink $SCRIPT_DIR/.config/nvim $HOME/.config/nvim
fi
# === tmux
if type tmux > /dev/null 2>&1; then
  create_symlink $SCRIPT_DIR/.tmux.conf $HOME/.tmux.conf
fi
# === vifm
if type vifm > /dev/null 2>&1; then
  create_symlink $SCRIPT_DIR/.config/vifm/vifmrc $HOME/.config/vifm/vifmrc
fi
# === vim
if type vim > /dev/null 2>&1; then
  create_symlink $SCRIPT_DIR/.config/vim/init.vim $HOME/.vimrc
  create_symlink $SCRIPT_DIR/.config/vim $HOME/.config/vim
fi
# === yq
if ! type yq > /dev/null 2>&1; then _install_yq; fi

