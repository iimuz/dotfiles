#!/usr/bin/env bash
#
# asdfの設定ファイル。

# === PATHの削除
if [ -n "$ASDF_DIR" ]; then
  remove_path "$ASDF_DIR/bin"
fi
if [ -n "$ASDF_DATA_DIR" ]; then
  remove_path "$ASDF_DATA_DIR/shims"
fi

# === Gurad if command does not exist.
# asdfの判定はhomebrewで導入しておりパスが設定されているか
if [ ! -f "$HOMEBREW_PREFIX/opt/asdf/libexec/asdf.sh" ]; then return 0; fi

# === data dir
# ASDF_DIRについては、homebrewの場所が異なるので別のパスになるので、そのまま
export ASDF_DATA_DIR="$HOME/.asdf"
if [ "$(uname)" = "Darwin" ]; then  # MacOS
  if [ "$(uname -m)" = "arm64" ]; then  # Apple silicon
    export ASDF_DATA_DIR="$HOME/.asdf-arm64"
  else  # Intel
    export ASDF_DATA_DIR="$HOME/.asdf-x64"
  fi
fi

source "$HOMEBREW_PREFIX/opt/asdf/libexec/asdf.sh"

