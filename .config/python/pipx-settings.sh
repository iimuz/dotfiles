#!/usr/local/env bash
#
# pipx の設定

# === 既に設定がある場合は、PATHから削除
# guradより前に設置しないと切り替え先に存在しない場合に削除できない
# MacOSでarchを切り替える際などに以前の設定が残っていると反対のarchのツールが動くため削除
if [ -n "$PIPX_BIN_DIR" ]; then
  remove_path "$PIPX_BIN_DIR"
fi

# Gurad if command does not exist.
if ! type pipx > /dev/null 2>&1; then return 0; fi

# === pipxの環境変数設定
export PIPX_BIN_DIR="$HOME/.local/pipx/bin"
export PIPX_HOME="$HOME/.local/pipx/pipx"
if [ "$(uname)" = "Darwin" ]; then  # MacOS
  if [ "$(uname -m)" = "arm64" ]; then  # Apple silicon
    export PIPX_BIN_DIR="$HOME/.local/pipx-arm64/bin"
    export PIPX_HOME="$HOME/.local/pipx-arm64/pipx"
  else  # Intel
    export PIPX_BIN_DIR="$HOME/.local/pipx-x64/bin"
    export PIPX_HOME="$HOME/.local/pipx-x64/pipx"
  fi
fi
export PATH="$PIPX_BIN_DIR:$PATH"

