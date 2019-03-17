#!/bin/bash
#
# GCE でインスタンスを借りた場合に、環境構築するためのスクリプトです。

sudo apt update
sudo apt upgrade -y
sudo apt autoremove -y
sudo apt clean

source $(pwd)/setup.sh

# docker 環境の構築
install_command docker $SCRIPT_PATH/docker-ubuntu.sh
for file in $(find $BIN_PATH -type f | gawk -F/ '{print $NF}'); do
  create_symlink $BIN_PATH/$file $BIN_HOME/$file
done

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
