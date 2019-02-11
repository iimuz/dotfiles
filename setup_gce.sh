#!/bin/bash
#
# GCE でインスタンスを借りた場合に、環境構築するためのスクリプトです。

source $(pwd)/setup.sh

# docker 環境の構築
install_command docker $SCRIPT_PATH/docker-ubuntu.sh

# gcloud 環境の構築
# gcloud はコマンド自体は docker で行うため、
# docker gcloud を呼びやすくする alias のみ設定します。
create_symlink $CONFIG_PATH/gcloud/alias.inc $CONFIG_HOME/gcloud/alias.inc
set_bashrc $CONFIG_HOME/gcloud/alias.inc

# peco 環境の構築
install_command peco $SCRIPT_PATH/peco.sh
create_symlink $CONFIG_PATH/peco/alias.inc $CONFIG_HOME/peco/alias.inc
set_bashrc $CONFIG_HOME/peco/alias.inc

# tmux の plugin 環境の構築
if [ ! -d ~/.config/tmux/plugins ]; then
  echo "install tmux-plugins"
  bash $SCRIPT_PATH/tmux-plugins.sh
else
  echo "already installed tmux-plugins"
fi
