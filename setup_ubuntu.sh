#!/bin/bash
#
# Ubuntu サーバで、環境構築するためのスクリプトです。

sudo -E apt update
sudo -E apt upgrade -y
sudo -E apt autoremove -y
sudo -E apt clean

source $(pwd)/setup.sh

# docker 環境の構築
install_command docker $SCRIPT_PATH/docker-ubuntu.sh
create_symlink_in_dir $BIN_PATH/use_docker $BIN_HOME

# peco 環境の構築
install_command peco $SCRIPT_PATH/peco.sh
create_symlink $CONFIG_PATH/peco/alias.inc $CONFIG_HOME/peco/alias.inc
set_bashrc $CONFIG_HOME/peco/alias.inc

# jq の環境構築
install_command jq $SCRIPT_PATH/jq.sh
mv jq $BIN_HOME/

# tmux の plugin 環境の構築
if [ ! -d ~/.tmux/plugins ]; then
  echo "install tmux-plugins"
  bash $SCRIPT_PATH/tmux-plugins.sh
else
  echo "already installed tmux-plugins"
fi

