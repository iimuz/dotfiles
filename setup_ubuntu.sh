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
for file in $(find $BIN_PATH -type f | gawk -F/ '{print $NF}'); do
  create_symlink $BIN_PATH/$file $BIN_HOME/$file
done

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
