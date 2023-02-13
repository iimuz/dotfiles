#!/usr/bin/env bash
#
# zshの設定

# Gurad if shell does not zsh.
if [[ "$SHELL" != *zsh* ]]; then return 0; fi

# === コマンド補完の有効化
autoload -Uz compinit promptinit
compinit

# === プロンプトテーマを使用
autoload -Uz promptinit
promptinit
# デフォルトのプロンプトを walters テーマに設定する
prompt walters
# macosの場合に現在のシェルのアーキテクチャを表示
if [ "$(uname)" = "Darwin" ]; then
  PROMPT="$(uname -m) $PROMPT"
fi

