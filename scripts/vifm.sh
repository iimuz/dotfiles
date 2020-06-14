#!/bin/sh
#
# Install vifm.

set -eu

# スクリプトのパスを取得
cwd=`dirname "${0}"`
expr "${0}" : "/.*" > /dev/null || cwd=`(cd "${cwd}" && pwd)`

# 各種パス設定
BASE_DIR=`(cd "$cwd/.." && pwd)`
XDG_CONFIG_HOME=${XDG_CONFIG_HOME:-$HOME/.config}

sudo -E apt install -y --no-install-recommends vifm

mkdir -p $XDG_CONFIG_HOME/vifm
ln -s $BASE_DIR/.config/vifm/vifmrc $XDG_CONFIG_HOME/vifm/vifmrc
