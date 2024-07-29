#!/usr/bin/env bash
#
# zshの設定

# Gurad if shell does not zsh.
if [[ "$SHELL" != *zsh* ]]; then return 0; fi

# === コマンド履歴
HISTFILE=~/.zsh_history # 履歴ファイルの場所を指定
HISTSIZE=10000 # 保存する履歴の最大数
SAVEHIST=10000 # 読み込む履歴の最大数
setopt APPEND_HISTORY             # シェルが終了する度にコマンド履歴をファイルに追加
setopt SHARE_HISTORY              # 他のシェルと履歴を共有
setopt INC_APPEND_HISTORY         # コマンドが実行される度に履歴をファイルに追加
setopt HIST_IGNORE_DUPS           # 直前と同じコマンドを履歴に追加しない
setopt HIST_IGNORE_SPACE          # 前にスペースを付けたコマンドを履歴に追加しない
setopt HIST_FIND_NO_DUPS          # 重複する履歴を削除
setopt HIST_REDUCE_BLANKS         # 履歴に保存する際に余分な空白を削除

# 履歴保存時に時刻を記録したくないための設定
# 時刻が記録されるため同じコマンドが重複削除されていない
# - 記録の例: `: 1718753947:0;echo "gege"`
# ただし、以下の設定を行っても時刻記録は止められていない
# export HISTTIMEFORMAT=""
# unsetopt EXTENDED_HISTORY         # 履歴保存時にセッション番号を記録しない
# setopt HIST_SAVE_BY_COPY

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

# starshipがインストール済みの場合は有効化する
if type starship > /dev/null 2>&1; then
  eval "$(starship init zsh)"
fi
