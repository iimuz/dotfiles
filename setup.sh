#!/bin/bash

# symlink 先がない場合のみ作成する
function create_symlink() {
  src=$1
  dst=$2
  if [ ! -e $2 ]; then
    echo "symlink $1 to $2"
    mkdir -p $(dirname "$dst")
    ln -s $src $dst
  else
    echo "already exist $2"
  fi
}

# bashrc に追加の設定ファイルを記載する
function create_symlink_and_set_bashrc() {
  filename=$1
  cat <<EOF >> ~/.bashrc

if [ -f '${filename}' ]; then . '${filename}'; fi
EOF
}

# 設定ファイルを配置する
create_symlink $(pwd)/.gitconfig ~/.gitconfig
create_symlink $(pwd)/.inputrc ~/.inputrc
create_symlink $(pwd)/.tmux.confg ~/.tmux.conf
create_symlink $(pwd)/.config/nvim/init.vim ~/.vimrc

set_bashrc ~/.config/gcloud/alias.inc
create_symlink $(pwd)/.config/gcloud/alias.inc ~/.config/gcloud/alias.inc

set_bashrc ~/.config/peco/alias.inc
create_symlink $(pwd)/.config/peco/alias.inc ~/.config/peco/alias.inc

