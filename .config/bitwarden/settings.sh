#!/bin/bash
#
# Setting for Bitwarden.

# Gurad if command does not exist.
if ! type bw >/dev/null 2>&1; then return 0; fi

# 自動 lock 付きの unlock
function bw-unlock() {
  local -r TIMEOUT=60 # 自動ロックまでの時間 (秒)
  local -r PID_FILE="/tmp/bw_auto_lock.pid"

  # 既存のタイマーがあればキャンセル (時間を延長するため)
  if [ -f "$PID_FILE" ]; then
    local OLD_PID
    OLD_PID=$(cat "$PID_FILE")
    readonly OLD_PID

    if ps -p "$OLD_PID" >/dev/null; then
      kill "$OLD_PID" 2>/dev/null
      echo "Previous auto-lock timer cancelled."
    fi
    rm "$PID_FILE"
  fi

  # まだロックされている場合のみ解除を実行
  if ! bw status | grep -q '"status":"unlocked"'; then
    BW_SESSION=$(bw unlock --raw) || {
      echo "Failed to unlock."
      return 1
    }
    export BW_SESSION
  fi

  # 3. 新しいタイマーをセット
  echo "Bitwarden unlocked. Auto-lock set for ${TIMEOUT} seconds."

  (
    sleep $TIMEOUT
    bw lock
    rm "$PID_FILE" 2>/dev/null
  ) &

  # PIDを保存
  echo $! >"$PID_FILE"
}
