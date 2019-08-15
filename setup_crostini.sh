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

# gpg 環境の構築
install_command gpg $SCRIPT_PATH/gpg.sh

# peco 環境の構築
install_command peco $SCRIPT_PATH/peco.sh $BIN_HOME arm64
create_symlink $CONFIG_PATH/peco/alias.inc $CONFIG_HOME/peco/alias.inc
set_bashrc $CONFIG_HOME/peco/alias.inc

# tmux の plugin 環境の構築
if [ ! -d ~/.tmux/plugins ]; then
  echo "install tmux-plugins"
  bash $SCRIPT_PATH/tmux-plugins.sh
else
  echo "already installed tmux-plugins"
fi

