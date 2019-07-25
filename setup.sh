#!/bin/bash

# symlink 先がない場合のみ作成する
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

# 特定ディレクトリ下のファイルへのシンボリックリンクを張る
function create_symlink_in_dir() {
  src_dir=$1
  dst_dir=$2
  for file in $(find $src_dir -type f | gawk -F/ '{print $NF}'); do
    create_symlink $src_dir/$file $dst_dir/$file
  done
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

# bashrc に追加の設定ファイルを記載する
function set_bashrc() {
  filename=$1

  # 既に設定ファイルが存在する場合は何もしない
  if grep $filename -l ~/.bashrc > /dev/null 2>&1; then
    echo "already setting in bashrc: $filename"
    return 0
  fi

  # 設定ファイルに読み込みようパスを追記
  echo "set load setting in bashrc: $filename"
  cat <<EOF >> ~/.bashrc

if [ -f '${filename}' ]; then . '${filename}'; fi
EOF
}

# 共通パスの設定
CONFIG_HOME=~/.config
BIN_HOME=~/.local/bin

CONFIG_PATH=$(pwd)/.config
SCRIPT_PATH=$(pwd)/scripts
BIN_PATH=$(pwd)/.local/bin

# 基本の設定ファイルのみリンクを作成する
create_symlink $(pwd)/.gitconfig ~/.gitconfig
sudo chmod +x /usr/share/doc/git/contrib/credential/netrc/git-credential-netrc

create_symlink $(pwd)/.config/git/ignore ~/.config/git/ignore
create_symlink $(pwd)/.inputrc ~/.inputrc
create_symlink $(pwd)/.tmux.conf ~/.tmux.conf
create_symlink $(pwd)/.config/nvim/init.vim ~/.vimrc

create_symlink $CONFIG_PATH/bash $CONFIG_HOME/bash
set_bashrc $CONFIG_HOME/bash/xdg-base.sh

# ユーザ専用の実行ファイルを配置する場所を追加
mkdir -p $BIN_HOME
if ! grep "$(readlink -f $BIN_HOME)" $PATH > /dev/null 2>&1; then
  cat <<EOF >> ~/.bashrc

if [ -d $BIN_HOME ]; then
  export PATH=$(readlink -f $BIN_HOME):\$PATH
fi
EOF
fi

