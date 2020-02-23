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
  for file in $(find $src_dir -type f | awk -F/ '{print $NF}'); do
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
CONFIG_HOME=$HOME/.config
BIN_HOME=$HOME/.local/bin

CONFIG_PATH=$(pwd)/.config
SCRIPT_PATH=$(pwd)/scripts
BIN_PATH=$(pwd)/.local/bin

# 基本の設定ファイルのみリンクを作成する
create_symlink $(pwd)/.gitconfig $HOME/.gitconfig
create_symlink $(pwd)/.config/git/ignore $HOME/.config/git/ignore
create_symlink $(pwd)/.inputrc $HOME/.inputrc
create_symlink $(pwd)/.tmux.conf $HOME/.tmux.conf
create_symlink $(pwd)/.config/nvim/init.vim $HOME/.vimrc
create_symlink $CONFIG_PATH/bash $CONFIG_HOME/bash
set_bashrc $CONFIG_HOME/bash/xdg-base.sh
set_bashrc $CONFIG_HOME/bash/settings.sh

# tmux の plugin 環境の構築
if [ ! -d ~/.tmux/plugins ]; then
  echo "install tmux-plugins"
  bash $SCRIPT_PATH/tmux-plugins.sh
else
  echo "already installed tmux-plugins"
fi

# シングルバイナリコマンド
install_command docui $SCRIPT_PATH/docui.sh
install_command gotop $SCRIPT_PATH/gotop.sh
install_command hugo $SCRIPT_PATH/hugo.sh
install_command lazygit $SCRIPT_PATH/lazygit.sh
install_command rg $SCRIPT_PATH/ripgrep.sh

install_command bw $SCRIPT_PATH/bitwarden.sh
create_symlink $(pwd)/.local/bin/git-credential-bw $BIN_HOME/git-credential-bw
create_symlink $(pwd)/.config/bitwarden/settings.sh $CONFIG_HOME/bitwarden/settings.sh
set_bashrc $CONFIG_HOME/bitwarden/settings.sh

install_command fzf $SCRIPT_PATH/fzf.sh
create_symlink $(pwd)/.config/fzf/fzf.bash $CONFIG_HOME/fzf/fzf.bash
set_bashrc $CONFIG_HOME/fzf/fzf.bash

# neovim
install_command nvim $SCRIPT_PATH/neovim-ubuntu.sh
create_symlink $CONFIG_PATH/nvim $CONFIG_HOME/nvim
create_symlink $CONFIG_PATH/pt $CONFIG_HOME/pt
create_symlink $(pwd)/.globalrc ~/.globalrc

# gcloud
install_command gcloud $SCRIPT_PATH/gcloud.sh
create_symlink $CONFIG_PATH/gcloud/alias.inc $CONFIG_HOME/gcloud/alias.inc
set_bashrc $CONFIG_HOME/gcloud/alias.inc

# docker 環境の構築
install_command docker $SCRIPT_PATH/docker-ubuntu.sh
create_symlink_in_dir $BIN_PATH/use_docker $BIN_HOME

# x11 forwarding 用設定を追加
if ! grep "$(readlink -f ~/.bashrc)" "export DISPLAY=localhost:0.0" > /dev/null 2>&1; then
  echo "export DISPLAY=localhost:0.0" >> ~/.bashrc
fi
