#!/usr/bin/env bash
#
# neovimが導入されている場合の追加設定

# Guard if command does not exist.
if ! type go > /dev/null 2>&1; then return 0; fi

# nvim実行とともにterminalを起動するコマンド
alias nterm='nvim "+terminal"'

