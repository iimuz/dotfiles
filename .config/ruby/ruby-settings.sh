#!/usr/local/env bash
#
# ruby の設定

# Gurad if command does not exist.
if ! type ruby > /dev/null 2>&1; then return 0; fi

# === gemの環境変数設定
export GEM_HOME="$HOME/.local/gem"
export GEM_PATH="$HOME/.local/gem"
if [ "$(uname)" = "Darwin" ]; then  # MacOS
  if [ "$(uname -m)" = "arm64" ]; then  # Apple silicon
    export GEM_HOME="$HOME/.local/gem-arm64"
    export GEM_PATH="$HOME/.local/gem-arm64"
  else  # Intel
    export GEM_HOME="$HOME/.local/gem-x64"
    export GEM_PATH="$HOME/.local/gem-x64x"
  fi
fi

