#!/usr/bin/env bash
#
# pyenvの設定ファイル

# Gurad if command does not exist.
if ! type pyenv > /dev/null 2>&1; then return 0; fi

# === mac環境において、arm/rosettaでインストール先を切り替える
if [ "$(uname)" = "Darwin" ]; then  # MacOS
  if [ "$(uname -m)" = "arm64" ]; then  # Arm
    export PYENV_ROOT="$HOME/.pyenv_arm64"
    export PATH="$HOME/.pyenv_arm64/bin:$PATH"
    eval "$(pyenv init -)"
  else  # Intel
    export PYENV_ROOT="$HOME/.pyenv_x64"
    export PATH="$HOME/.pyenv_x64/bin:$PATH"
    eval "$(pyenv init -)"
  fi
fi

