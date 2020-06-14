#!/bin/bash
#
# Setup script.

# Create symlink if link does not exist.
function create_symlink() {
  src=$1
  dst=$2
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
function install_command() {
  command=$1
  script=$2

  # コマンドがインストール済みの場合は終了
  if type $command > /dev/null 2>&1; then
    echo "already installed: $command"
    return 0
  fi

  echo "install: $command using $script"
  bash $script ${@:3}
}

# Add loading file in .bashrc.
function set_bashrc() {
  filename="$1"

  # if setting exits in .bashrc, do nothing.
  if grep $filename -l $HOME/.bashrc > /dev/null 2>&1; then
    echo "already setting in bashrc: $filename"
    return 0
  fi

  # Add file path.
  echo "set load setting in bashrc: $filename"
  echo -e "if [ -f \"${filename}\" ]; then . \"${filename}\"; fi\n" >> $HOME/.bashrc
}

# Add loading file in .vimrc.
function set_vimrc() {
  search_dir="$1"

  # if setting exits in .bashrc, do nothing.
  if grep $search_dir -l $HOME/.vimrc > /dev/null 2>&1; then
    echo "already setting in vimrc: $search_dir"
    return 0
  fi

  # Add file path.
  echo "set load setting in vimrc: $search_dir"
  echo -e "call map(sort(split(globpath(\"$search_dir\", \".vimrc\"))), {->[execute('exec \"so\" v:val')]})\n" >> $HOME/.vimrc
}

# 共通パスの設定
CONFIG_PATH=$(pwd)/.config
SCRIPT_PATH=$(pwd)/scripts

# 場所が固定されている基本設定ファイルを設置
create_symlink $(pwd)/.gitconfig $HOME/.gitconfig
create_symlink $(pwd)/.config/git/ignore $HOME/.config/git/ignore
create_symlink $(pwd)/.inputrc $HOME/.inputrc
create_symlink $(pwd)/.tmux.conf $HOME/.tmux.conf

# .bashrc から読み込む設定ファイルの親を設定
set_bashrc $CONFIG_PATH/bash/settings.sh

set_vimrc $CONFIG_PATH/vim

# シングルバイナリコマンド
install_command bat $SCRIPT_PATH/bat.sh
install_command bw $SCRIPT_PATH/bitwarden.sh
install_command docui $SCRIPT_PATH/docui.sh
install_command exa $SCRIPT_PATH/exa.sh
install_command fd $SCRIPT_PATH/fd.sh
install_command fzf $SCRIPT_PATH/fzf.sh
install_command gotop $SCRIPT_PATH/gotop.sh
install_command hugo $SCRIPT_PATH/hugo.sh
install_command jq $SCRIPT_PATH/jq.sh
install_command lazygit $SCRIPT_PATH/lazygit.sh
install_command procs $SCRIPT_PATH/procs.sh
install_command rg $SCRIPT_PATH/ripgrep.sh
