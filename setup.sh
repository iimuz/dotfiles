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

# コマンドがインストールされていないときにインストールスクリプトを呼び出す
# ここでは使っていないが、個別環境での構築で、共通して利用する
# function install_command() {
#   local readonly command=$1
#   local readonly script=$2

#   # コマンドがインストール済みの場合は終了
#   if type $command > /dev/null 2>&1; then
#     echo "already installed: $command"
#     return 0
#   fi

#   echo "install: $command using $script"
#   bash $script ${@:3}
# }

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

# 共通パスの設定
SCRIPT_DIR=$(cd $(dirname ${BASH_SOURCE:-0}); pwd)
CONFIG_PATH=$SCRIPT_DIR/.config
SCRIPT_PATH=$SCRIPT_DIR/scripts

# 場所が固定されている基本設定ファイルを設置
create_symlink $SCRIPT_DIR/.gitconfig $HOME/.gitconfig
create_symlink $SCRIPT_DIR/.config/git/ignore $HOME/.config/git/ignore
create_symlink $SCRIPT_DIR/.inputrc $HOME/.inputrc
create_symlink $SCRIPT_DIR/.tmux.conf $HOME/.tmux.conf

# .bashrc から読み込む設定ファイルの親を設定
set_bashrc $CONFIG_PATH/bash/settings.sh
