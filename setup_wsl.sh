#!/bin/bash
#
# wsl ubuntu 環境に必要なパッケージを一括インストールします。
# インストール済みのパッケージに関しては処理しないようにしています。

sudo apt update
sudo apt upgrade -y
sudo apt autoremove -y
sudo apt clean

# 基本設定を行う
source $(pwd)/setup.sh

# gcloud 環境の構築
install_command gcloud $SCRIPT_PATH/gcloud.sh
create_symlink $CONFIG_PATH/gcloud/alias.inc $CONFIG_HOME/gcloud/alias.inc
set_bashrc $CONFIG_HOME/gcloud/alias.inc

# ghq 環境の構築
install_command ghq $SCRIPT_PATH/ghq.sh

# git-svn 環境の構築
install_command git-svn $SCRIPT_PATH/git-svn.sh

# gpg 環境の構築
install_command gpg $SCRIPT_PATH/gpg.sh

# hugo 環境の構築
install_command hugo $SCRIPT_PATH/hugo.sh

# jq 環境の構築
install_command jq $SCRIPT_PATH/jq.sh

# neovim 環境の構築
install_command nvim $SCRIPT_PATH/neovim-ubuntu.sh
create_symlink $CONFIG_PATH/nvim $CONFIG_HOME/nvim
create_symlink $CONFIG_PATH/pt $CONFIG_HOME/pt
create_symlink $(pwd)/.globalrc ~/.globalrc

# peco 環境の構築
install_command peco $SCRIPT_PATH/peco.sh
create_symlink $CONFIG_PATH/peco/alias.inc $CONFIG_HOME/peco/alias.inc
set_bashrc $CONFIG_HOME/peco/alias.inc

# tmux の plugin 環境の構築
if [ ! -d ~/.tmux/plugins ]; then
  echo "install tmux-plugins"
  bash $SCRIPT_PATH/tmux-plugins.sh
else
  echo "already installed tmux-plugins"
fi

# x11 forwarding 用設定を追加
if ! grep "$(readlink -f ~/.bashrc)" "export DISPLAY=localhost:0.0" > /dev/null 2>&1; then
  echo "export DISPLAY=localhost:0.0" >> ~/.bashrc
fi

