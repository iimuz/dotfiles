#!/bin/bash
#
# Install tmux plugins and settings
#
# 追加作業として下記が必要になります。
#
# 1. 本スクリプトの実行後に Prefix + I キーでプラグインをインストール

# tmux のプラグインマネージャを設定
TMUX_PLUGINS_DIR=~/.tmux/plugins
mkdir -p $TMUX_PLUGINS_DIR
pushd $TMUX_PLUGINS_DIR
git clone https://github.com/tmux-plugins/tpm
popd

