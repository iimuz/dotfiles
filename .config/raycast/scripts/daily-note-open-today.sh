#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Daily Note - Open Today's Note
# @raycast.mode compact
# @raycast.icon 🗓️
# @raycast.packageName Automation

set -E -e -u -o pipefail

SCRIPT_NAME=$(basename "${0}")
readonly SCRIPT_NAME

function log_info() {
  local _message="$1"
  echo "[$(date +'%Y-%m-%d %H:%M:%S')] ($SCRIPT_NAME) [INFO] $_message" >&2
}

function log_warn() {
  local _message="$1"
  echo "[$(date +'%Y-%m-%d %H:%M:%S')] ($SCRIPT_NAME) [WARN] $_message" >&2
}

function log_error() {
  local _message="$1"
  echo "[$(date +'%Y-%m-%d %H:%M:%S')] ($SCRIPT_NAME) [ERROR] $_message" >&2
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
  if [ ! -f "$TARGET_FILE" ]; then
    log_warn "$TARGET_DATE のファイルが見つかりません"
    return 1
  fi

  # 対象のファイルを開く
  local -r GHOSTTY_BIN="/Applications/Ghostty.app/Contents/MacOS/ghostty"
  if [ ! -x "$GHOSTTY_BIN" ]; then
    log_error "ghostty not found or not executable at $GHOSTTY_BIN"
    return 1
  fi
  "$GHOSTTY_BIN" -e sh -c "nvim +$ '$TARGET_FILE'" &
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  main "$@"
fi
