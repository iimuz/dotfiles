#!/bin/bash
#
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

# Add loading file in .bashrc.
function set_bashrc() {
  local readonly filename="$1"

  # if setting exits in .bashrc, do nothing.
  if grep $filename -l $HOME/.bashrc > /dev/null 2>&1; then
    echo "already setting in bashrc: $filename"
    return 0
  fi

  # Add file path.
  echo "set load setting in bashrc: $filename"
  echo -e "if [ -f \"${filename}\" ]; then . \"${filename}\"; fi\n" >> $HOME/.bashrc
}

# === 共通パスの設定
readonly SCRIPT_DIR=$(cd $(dirname ${BASH_SOURCE:-0}); pwd)
readonly CONFIG_PATH=$SCRIPT_DIR/.config
readonly SCRIPT_PATH=$SCRIPT_DIR/scripts

# === Install [homebrew](https://brew.sh/index_ja)
if ! type brew > /dev/null 2>&1; then
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

# === Install softwaare
# homebrewを利用するための設定を追記して再読み込み
set_bashrc $CONFIG_PATH/homebrew/homebrew-bundle.sh
source ~/.bashrc
# homebrewを利用して各種ソフトウェアをインストール
brew bundle

# 各種設定ファイルの配置もしくは読み込み設定
# 特定の場所に配置する必要のない設定ファイルは、 `bash/settings.sh` から読み込み設定を記述
# === bash
if type bash > /dev/null 2>&1; then
  create_symlink $SCRIPT_DIR/.inputrc $HOME/.inputrc
  set_bashrc $CONFIG_PATH/bash/settings.sh
  set_bashrc $CONFIG_PATH/bash/aliases.sh
  set_bashrc $CONFIG_PATH/bash/x11.sh
  set_bashrc $CONFIG_PATH/bash/xdg-base.sh
fi
# === bitwarden
if type bw > /dev/null 2>&1; then
  set_bashrc $CONFIG_PATH/bitwarden/settings.sh
fi
# === fzf
if type fzf > /dev/null 2>&1; then
  set_bashrc $CONFIG_PATH/fzf/fzf.bash
fi
# === git
if type git > /dev/null 2>&1; then
  create_symlink $SCRIPT_DIR/.gitconfig $HOME/.gitconfig
  create_symlink $SCRIPT_DIR/.config/git/ignore $HOME/.config/git/ignore
  set_bashrc $CONFIG_PATH/git/settings.sh
fi
# === npm
if type npm > /dev/null 2>&1; then
  set_bashrc $CONFIG_PATH/npm/npm.sh
fi
# === tmux
if type tmux > /dev/null 2>&1; then
  create_symlink $SCRIPT_DIR/.tmux.conf $HOME/.tmux.conf
fi
# === vim
if type vim > /dev/null 2>&1; then
  create_symlink $SCRIPT_DIR/.config/nvim/init.vim $HOME/.vimrc
  create_symlink $SCRIPT_DIR/.config/nvim $HOME/.config/vim
fi
# === vscode
if type code > /dev/null 2>&1; then
  set_bashrc $CONFIG_PATH/vscode/vscode.sh
fi
