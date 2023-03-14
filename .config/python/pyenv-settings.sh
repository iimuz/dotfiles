#!/usr/bin/env bash
#
# pyenvの設定ファイル

# === 既に設定されている場合はPATHを削除
# guradより前に設置しないと切り替え先に存在しない場合に削除できない
if [ -n "$PYENV_ROOT" ]; then
  remove_path "$PYENV_ROOT/bin"
  remove_path "$PYENV_ROOT/shims"
fi

# === Gurad if command does not exist.
if ! type pyenv > /dev/null 2>&1; then return 0; fi

# === 有効化
# デフォルトの場合を設定
export PYENV_ROOT="$HOME/.pyenv"
# mac環境において、arm/rosettaでインストール先を切り替える
if [ "$(uname)" = "Darwin" ]; then  # MacOS
  if [ "$(uname -m)" = "arm64" ]; then  # Arm
    export PYENV_ROOT="$HOME/.pyenv_arm64"
  else  # Intel
    export PYENV_ROOT="$HOME/.pyenv_x64"
  fi
fi
export PATH="$PYENV_ROOT/shims:$PYENV_ROOT/bin:$PATH"

