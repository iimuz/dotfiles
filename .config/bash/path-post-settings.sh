#!/usr/bin/env bash
#
# パスの重複削除を実行する。

if [ -n "$ZSH_VERSION" ]; then  # zshの場合
  typeset -U path PATH
else  # zshではないのでawkで重複削除
  export PATH=$(printf %s "$PATH" | awk -v RS=: -v ORS=: '!arr[$0]++')
fi

