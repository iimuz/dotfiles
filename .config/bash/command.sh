#!/usr/bin/env bash

# ログファイルを特定の場所に保存しつつコマンド実行する
# ex) log_tee echo "hello world"
#   -> {timestamp}-{normal/error}.log というファイルに標準出力と標準エラーが保存されつつ、コンソールにも表示される。
# `LOG_TEE_DIR` 環境変数がある場合は、当該フォルダをログ保存フォルダのルートとして利用する。
function log_tee() {
  # 保存先のファイル名などを日付情報から作成する
  local -r DATETIME=$(date "+%Y%m%d%H%M%S")
  local -r MONTH=${DATETIME:4:2}
  local -r DATE=${DATETIME:0:8}
  local -r LOG_ROOT=${LOG_TEE_DIR:-"$HOME/workspace"}
  local SAVE_DIR
  SAVE_DIR=$(cd "${LOG_ROOT}/${MONTH}/${DATE}" && pwd)
  readonly SAVE_DIR
  local -r LOG_NORMAL="${DATETIME}-normal.log"
  local -r LOG_ERROR="${DATETIME}-error.log"

  # コマンド実行
  "$@" 1> >(tee "${SAVE_DIR}/${LOG_NORMAL}" >&1) 2> >(tee "${SAVE_DIR}/${LOG_ERROR}" >&2)
}

# OSC 52 を利用したクリップボードコピー関数
function osc52copy() {
  local DATA
  DATA=$(cat "$@" | base64 | tr -d '\n')
  readonly DATA

  if [ -n "$TMUX" ]; then
    printf "\033Ptmux;\033\033]52;c;%s\007\033\\" "$DATA"
  else
    printf "\033]52;c;%s\007" "$DATA"
  fi
}
