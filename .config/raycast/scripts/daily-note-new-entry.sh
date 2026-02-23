#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Daily Note - Quick Add
# @raycast.mode silent
# @raycast.icon 📥
# @raycast.packageName Automation

set -E -e -u -o pipefail

SCRIPT_NAME=$(basename "${0}")
readonly SCRIPT_NAME

TEMP_FILE="$(mktemp "/tmp/${SCRIPT_NAME}.XXXXXX.md")"
readonly TEMP_FILE

LOCK_FILE="/tmp/raycast_ghostty_lock_$$"
readonly LOCK_FILE

DEBUG_FLAG=false
readonly DEBUG_FLAG

function _log_header() {
  if [ "$DEBUG_FLAG" == "false" ]; then
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

function cleanup() {
  rm -f "$TEMP_FILE"
  rm -f "$LOCK_FILE"
}

trap 'err ${LINENO} "$BASH_COMMAND"' ERR
trap 'cleanup; exit 130' INT TERM
trap cleanup EXIT

function usage() {
  cat <<EOF
Usage: ${SCRIPT_NAME} [OPTIONS]

Appends the currently selected text to a daily note at $HOME/daily_note/YYYYMMDD.md.

OPTIONS:
  -h, --help      Show this help message
  -v, --verbose   Enable verbose output

EXAMPLE:
  # Append selection to today's daily note
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

  # 保存先設定
  local -r TARGET_DATE="$(date +%Y%m%d)"
  local -r TARGET_DIR="$HOME/daily_note"
  local -r TARGET_FILE="$TARGET_DIR/$TARGET_DATE.md"
  mkdir -p "$TARGET_DIR"

  # メモの入力を一時ファイルに保存
  local -r GHOSTTY_BIN="/Applications/Ghostty.app/Contents/MacOS/ghostty"
  if [ ! -x "$GHOSTTY_BIN" ]; then
    log_error "ghostty not found or not executable at $GHOSTTY_BIN"
    return 1
  fi
  : >"$LOCK_FILE" # ghostty 用のロックファイルを作成（空ファイルを作る）
  # ghostty を起動し、エディタ終了時にロックファイルを削除する想定
  "$GHOSTTY_BIN" -e sh -c "nvim '$TEMP_FILE'; rm -f '$LOCK_FILE'" &
  while [ -f "$LOCK_FILE" ]; do
    sleep 1
  done

  # メモを daily note に追記
  local -r CONTENT=$(cat "$TEMP_FILE")
  if [ -z "${CONTENT}" ]; then
    log_warn "No content entered; skipping append"
    return 0
  fi

  # %s を使うことで、SELECTION内の特殊文字による意図しない挙動を防ぐ
  local -r TIMESTAMP="$(date +%Y-%m-%dT%H:%M:%S.000+09:00)"
  printf '\n## %s\n\n%s\n\n' "$TIMESTAMP" "$CONTENT" >>"$TARGET_FILE"

  log_info "Appended to $TARGET_DATE note"
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  main "$@"
fi
