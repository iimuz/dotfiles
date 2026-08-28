#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Toggle Handy Voice Input
# @raycast.mode silent

# Optional parameters:
# @raycast.icon 🎙️
# @raycast.packageName Handy

set -E -e -u -o pipefail

readonly STATE_FILE="/tmp/handy_voice_state"
readonly LOCK_DIR="/tmp/handy_voice_state.lock"
LOCK_ACQUIRED=false

SCRIPT_NAME=$(basename "${0}")
readonly SCRIPT_NAME

DEBUG_FLAG=false
readonly DEBUG_FLAG

function _log_header() {
  if [ "$DEBUG_FLAG" = false ]; then
    echo ""
    return
  fi

  local -r LEVEL="${1:-INFO}"
  echo "[$(date +'%Y-%m-%d %H:%M:%S')] ($SCRIPT_NAME) [$LEVEL]"
}

function log_info() {
  local -r _MESSAGE="$1"
  local -r _HEADER="$(_log_header "INFO")"
  echo "$_HEADER $_MESSAGE" >&2
}

function log_warn() {
  local -r _MESSAGE="$1"
  local -r _HEADER="$(_log_header "WARN")"
  echo "$_HEADER $_MESSAGE" >&2
}

function log_error() {
  local -r _MESSAGE="$1"
  local -r _HEADER="$(_log_header "ERROR")"
  echo "$_HEADER $_MESSAGE" >&2
}

function err() {
  log_error "Line $1: $2" >&2
  exit 1
}

function acquire_lock() {
  if mkdir "$LOCK_DIR" 2>/dev/null; then
    LOCK_ACQUIRED=true
    return 0
  fi

  # Raycast の silent モードでは stderr が見えないため、強制終了などで
  # 残ったロックを放置するとホットキーが無反応になり続ける。
  # スクリプトの実行は数秒で終わるので、1 分以上古いロックは残骸とみなす。
  if [ -n "$(find "$LOCK_DIR" -maxdepth 0 -mmin +1 2>/dev/null)" ]; then
    rmdir "$LOCK_DIR" 2>/dev/null || true
    if mkdir "$LOCK_DIR" 2>/dev/null; then
      LOCK_ACQUIRED=true
      return 0
    fi
  fi

  return 1
}

function cleanup() {
  if [ "$LOCK_ACQUIRED" = true ]; then
    rmdir "$LOCK_DIR" 2>/dev/null || true
  fi
}

trap 'err ${LINENO} "$BASH_COMMAND"' ERR
trap 'cleanup; exit 130' INT TERM
trap cleanup EXIT

function usage() {
  cat <<EOF
Usage: ${SCRIPT_NAME} [OPTIONS]

Starts a background audio recording.

OPTIONS:
  -h, --help      Show this help message
  -v, --verbose   Enable verbose output

EXAMPLE:
  # Start recording
  $ ${SCRIPT_NAME}
EOF
}

function main() {
  while [[ $# -gt 0 ]]; do
    case $1 in
      -h | --help)
        usage
        exit 0
        ;;
      -v | --verbose)
        set -x
        shift
        ;;
      *)
        log_error "Unknown option: $1"
        usage
        exit 1
        ;;
    esac
  done

  if ! acquire_lock; then
    log_info "already running; ignored"
    exit 0
  fi

  local SCRIPT_DIR
  SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" >/dev/null 2>&1 && pwd)"
  readonly SCRIPT_DIR

  local -r SWIFT_SRC="$SCRIPT_DIR/toggle-microphone.swift"
  local -r BIN="${XDG_CACHE_HOME:-$HOME/.cache}/raycast-scripts/toggle-microphone"

  if [ ! -x "$BIN" ] || [ "$SWIFT_SRC" -nt "$BIN" ]; then
    mkdir -p "$(dirname "$BIN")"
    if ! swiftc -O -o "$BIN.tmp.$$" "$SWIFT_SRC"; then
      rm -f "$BIN.tmp.$$"
      exit 1
    fi
    mv -f "$BIN.tmp.$$" "$BIN"
  fi

  if [ -f "$STATE_FILE" ]; then
    # ハンディON中 → 終了する
    # osascript -e 'tell application "System Events" to keystroke " " using {shift down, option down}'
    /Applications/Handy.app/Contents/MacOS/handy --toggle-post-process
    "$BIN" mute >/dev/null
    rm "$STATE_FILE"
    log_info "🔇 音声入力を終了"
  else
    # ハンディOFF → 開始する
    "$BIN" unmute >/dev/null
    sleep 0.3
    # osascript -e 'tell application "System Events" to keystroke " " using {shift down, option down}'
    /Applications/Handy.app/Contents/MacOS/handy --toggle-post-process
    touch "$STATE_FILE"
    log_info "🎙️ 音声入力を開始"
  fi

}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  main "$@"
fi
