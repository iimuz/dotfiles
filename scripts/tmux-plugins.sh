#!/bin/bash
#
# Install tmux plugins and settings
#
# 追加作業として下記が必要になります。
#
# 1. 本スクリプトの実行後に Prefix + I キーでプラグインをインストール

# スクリプトのパスを取得
cwd=`dirname "${0}"`
expr "${0}" : "/.*" > /dev/null || cwd=`(cd "${cwd}" && pwd)`

# tmux のプラグインマネージャを設定
TMUX_PLUGINS_DIR=~/.config/tmux/plugins
if [ ! -d $TMUX_PLUGINS_DIR ]; then
  mkdir -p $TMUX_PLUGINS_DIR
  pushd $TMUX_PLUGINS_DIR
  git clone https://github.com/tmux-plugins/tpm
  popd
fi

# tmux.conf の設置
TMUX_CONF_FILE="$cwd/../.tmux.conf"
if [ ! -f $TMUX_CONF_FILE ]; then
  pushd ~/
  ln -s "$cwd/../.tmux.conf"
  popd
fi
