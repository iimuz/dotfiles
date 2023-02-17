#!/usr/local/env bash
#
# nvmの設定を行う

# Gurad if command does not exist.
if [ ! -s "$(brew --prefix)/opt/nvm/nvm.sh" ]; then return 0; fi

# === nvmが既に有効化されている場合にPATHを削除
# nvmを検出できなかったため、NVM_DIRを検出し、NVM_DIRを含むフォルダを一括削除
if [ -n "$NVM_DIR" ]; then
  export PATH=$(echo $PATH | sed "s;$NVM_DIR/[^:]*:;;g")
fi

# === nvmの保存先設定
export NVM_DIR="$HOME/.nvm"
if [ "$(uname)" = "Darwin" ]; then  # MacOS
  # MacOSの場合はarm64/rosettaで保存先を分割
  if [ "$(uname -m)" = "arm64" ]; then  # Apple silicon
    export NVM_DIR="$HOME/.nvm-arm64"
  else  # Intel
    export NVM_DIR="$HOME/.nvm-x64"
  fi
fi

# === nvmの有効化
[ -s "$(brew --prefix)/opt/nvm/nvm.sh" ] && . "$(brew --prefix)/opt/nvm/nvm.sh"

# === 補完機能の読み込み
[ -s "$(brew --prefix)/opt/nvm/etc/bash_completion.d/nvm" ] && . "$(brew --prefix)/opt/nvm/etc/bash_completion.d/nvm"


