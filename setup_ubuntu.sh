#!/bin/bash
#
# Ubuntu サーバで、環境構築するためのスクリプトです。

source $(pwd)/setup.sh

# docker 環境の構築
install_command docker $SCRIPT_PATH/docker-ubuntu.sh
create_symlink_in_dir $BIN_PATH/use_docker $BIN_HOME

# tmux の plugin 環境の構築
if [ ! -d ~/.tmux/plugins ]; then
  echo "install tmux-plugins"
  bash $SCRIPT_PATH/tmux-plugins.sh
else
  echo "already installed tmux-plugins"
fi

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

install_command nvim $SCRIPT_PATH/nvim.sh
create_symlink $(pwd)/.config/nvim $CONFIG_HOME/nvim
create_symlink $(pwd)/.local/bin/nvim $BIN_HOME/nvim

create_symlink $(pwd)/.config/python $CONFIG_HOME/python
set_bashrc $CONFIG_HOME/python/settings.sh

