#!/usr/bin/env bash

# ログファイルを特定の場所に保存しつつコマンド実行する
# ex) log_tee echo "hello world"
#   -> {timestamp}-{normal/error}.log というファイルに標準出力と標準エラーが保存されつつ、コンソールにも表示される。
# `LOG_TEE_DIR` 環境変数がある場合は、当該フォルダをログ保存フォルダのルートとして利用する。
function _log_tee() {
  # 保存先のファイル名などを日付情報から作成する
  readonly local DATETIME=$(date "+%Y%m%d%H%M%S")
  readonly local MONTH=${DATETIME:4:2}
  readonly local DATE=${DATETIME:0:8}
  readonly local LOG_ROOT=${LOG_TEE_DIR:-"$HOME/workspace"}
  readonly local SAVE_DIR=$(cd "${LOG_ROOT}/${MONTH}/${DATE}"; pwd)
  readonly local LOG_NORMAL="${DATETIME}-normal.log"
  readonly local LOG_ERROR="${DATETIME}-error.log"

  # コマンド実行
  "$@" 1> >(tee "${SAVE_DIR}/${LOG_NORMAL}" >&1) 2> >(tee "${SAVE_DIR}/${LOG_ERROR}" >&2)
}

alias log_tee=_log_tee

