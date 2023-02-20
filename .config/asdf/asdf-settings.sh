#!/usr/bin/env bash
#
# asdfの設定ファイル。

# === Gurad if command does not exist.
# asdfの判定はhomebrewで導入しておりパスが設定されているか
if [ ! -f "$HOMEBREW_PREFIX/opt/asdf/libexec/asdf.sh" ]; then return 0; fi

# === data dir
export ASDF_DATA_DIR="$HOME/.asdf"
if [ "$(uname)" = "Darwin" ]; then  # MacOS
  if [ "$(uname -m)" = "arm64" ]; then  # Apple silicon
    export ASDF_DATA_DIR="$HOME/.asdf-arm64"
  else  # Intel
    export ASDF_DATA_DIR="$HOME/.asdf-x64"
  fi
fi

source "$HOMEBREW_PREFIX/opt/asdf/libexec/asdf.sh"

