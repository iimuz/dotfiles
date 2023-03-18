#!/usr/bin/env bash
#
# poetryの設定ファイル

# === Gurad if command does not exist.
if ! type poetry > /dev/null 2>&1; then return 0; fi

# === 保存先を設定
export POETRY_CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/pypoetry"
export POETRY_DATA_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/pypoetry"
export POETRY_CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache/share}/pypoetry"
# mac環境において、arm/rosettaでインストール先を切り替える
if [ "$(uname)" = "Darwin" ]; then  # MacOS
  if [ "$(uname -m)" = "arm64" ]; then  # Arm
    export POETRY_CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/pypoetry-arm64"
    export POETRY_DATA_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/pypoetry-arm64"
    export POETRY_CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache/share}/pypoetry-arm64"
  else  # Intel
    export POETRY_CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/pypoetry-x64"
    export POETRY_DATA_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/pypoetry-x64"
    export POETRY_CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache/share}/pypoetry-x64"
  fi
fi

