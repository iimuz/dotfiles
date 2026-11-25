#!/usr/bin/env bash
#
# Linux (aarch64) で、再取得や再生成ができるものを掃除する。
#
# sudo なしで、いつでも手動で実行できる。
# root が要る掃除 (journal、無効な snap) は update_aarch64.sh にある。

set -eu
set -o pipefail

STAMP_FILE="$HOME/.local/state/dotfiles/cleanup-aarch64-weekly"

# 呼び出し元のディレクトリに依存せずにツールを動かすため。
cd "$HOME"

show_free_space() {
  echo "Free space $1:"
  df -h "$HOME"
}

clean_every_run() {
  if type docker >/dev/null 2>&1; then
    docker image prune --force
  fi
}

# 週 1 回の掃除は、曜日ではなく前回の成功からの日数で決める。
# 失敗した回は次の実行でやり直す必要があるため。
weekly_cleanup_due() {
  local last
  if [ ! -f "$STAMP_FILE" ]; then
    return 0
  fi
  last=$(cat "$STAMP_FILE")
  if [[ ! "$last" =~ ^[1-9][0-9]*$ ]]; then
    return 0
  fi
  [ $(($(date +%s) - last)) -ge $((7 * 86400)) ]
}

record_weekly_cleanup() {
  mkdir -p "$(dirname "$STAMP_FILE")"
  date +%s >"$STAMP_FILE"
}

# uv cache prune に --force を付けない。使用中のキャッシュを壊さないため。
clean_uv() {
  local lock="$HOME/.cache/uv/.lock"
  local rc=0
  if [ ! -d "$HOME/.cache/uv" ] || ! type uv >/dev/null 2>&1; then
    return 0
  fi
  # ロックを待たずに確かめる。端末に常駐するプロセスが uv run で共有ロックを持ち続けることがあり、
  # uv cache prune は排他ロックを取るので、待つと掃除全体が止まるため。
  # 確かめた後はロックを持ち続けない。持ったままだと prune 自身がそのロックを待つため。
  # 確かめてから prune までの間に uv run が始まったときは、uv 自身のタイムアウトに任せる。
  # ロックのファイルが無いときは flock がファイルを作ってしまうので呼ばない。
  # -E 75 で競合とそれ以外の flock の失敗を分け、後者を使用中と取り違えて成功扱いにしない。
  # 条件の中では set -e が効かないので、終了コードは || で受ける。
  if [ -f "$lock" ]; then
    flock -n -E 75 "$lock" true || rc=$?
    if [ "$rc" -eq 75 ]; then
      echo "warning: uv cache is in use; skipped uv cache prune" >&2
      return 0
    elif [ "$rc" -ne 0 ]; then
      return "$rc"
    fi
  fi
  uv cache prune --cache-dir "$HOME/.cache/uv"
}

# mise prune と Playwright はここで扱わない。update_aarch64.sh が扱い、
# Playwright はリビジョン番号では使用中かどうかを判断できないため。
clean_weekly() {
  if type docker >/dev/null 2>&1; then
    # --all で全件消すのを週 1 回に限るのは、dangling だけでは参照の残るキャッシュが上限なく溜まり、
    # 全件消すと次のビルドが遅くなるため。
    docker builder prune --all --force
  fi
  # 消す場所は XDG_* や各ツールの設定から読まず、$HOME の下で名指しする (uv の --cache-dir も同じ)。
  # ターミナルは npmrc で ~/.cache/npm を、シェルの設定を読まないプロセスは既定の ~/.npm を使うので、両方を消す。
  # _npx は消さない。いつでも実行するので、npx で動いている常駐のツールが置き場所を失わないようにするため。
  for dir in "$HOME/.npm" "$HOME/.cache/npm"; do
    rm -rf "$dir/_cacache"
  done
  clean_uv
}

show_free_space before
clean_every_run
# 条件の中では set -e が効かないので、条件には判定だけを置く
if weekly_cleanup_due; then
  clean_weekly
  record_weekly_cleanup
fi
show_free_space after
