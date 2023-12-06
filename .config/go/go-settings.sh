#!/usr/bin/env bash
#
# go langの設定ファイル

# === 既に設定されている場合はPATHを削除
# guradより前に設置しないと切り替え先に存在しない場合に削除できない
if [ -n "$GOPATH" ]; then
  remove_path "$GOPATH/bin"
fi

# === Gurad if command does not exist.
if ! type go > /dev/null 2>&1; then return 0; fi

# === 有効化
# デフォルトの場合を設定
export GOPATH="$HOME/go"
# mac環境において、arm/rosettaでインストール先を切り替える
if [ "$(uname)" = "Darwin" ]; then  # MacOS
  if [ "$(uname -m)" = "arm64" ]; then  # Arm
    export GOPATH="$HOME/go"
  else  # Intel
    export GOPATH="$HOME/go-x64"
  fi
fi
export PATH="$GOPATH/bin:$PATH"

