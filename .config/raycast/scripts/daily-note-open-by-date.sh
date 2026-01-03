#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Daily Note - Open by Date
# @raycast.mode compact
# @raycast.icon 🗓️
# @raycast.packageName Automation
# @raycast.argument1 { "type": "text", "placeholder": "Empty for Today, -1 for Yesterday, or YYYY-MM-DD", "optional": true }

set -E -e -u -o pipefail

SCRIPT_NAME=$(basename "${0}")
readonly SCRIPT_NAME

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
  local -r INPUT="${1:-}" # 表示する日付情報
  shift

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

  # 対象とするDaily Noteの日付計算
  # - 引数なし: 今日
  # - 相対日付入力(-1, +1): n日分ずらす
  # - 直接入力(YYYY-MM-DD等): そのまま使用
  local -r TARGET_DIR="$HOME/daily_note"
  local -r DATE_FORMAT="%Y%m%d"
  local -r EXT=".md"
  target_date="$(date +%Y%m%d)"
  if [ -z "$INPUT" ]; then
    target_date=$(date +"$DATE_FORMAT")
  elif [[ "$INPUT" =~ ^[-+]?[0-9]+$ ]]; then
    target_date=$(date -v"${INPUT}d" +"$DATE_FORMAT")
  else
    target_date="$INPUT"
  fi
  local -r TARGET_FILE="$TARGET_DIR/$target_date$EXT"
  if [ ! -f "$TARGET_FILE" ]; then
    log_warn "$target_date のファイルが見つかりません"
    return 1
  fi

  # 対象のファイルを開く
  local -r GHOSTTY_BIN="/Applications/Ghostty.app/Contents/MacOS/ghostty"
  if [ ! -x "$GHOSTTY_BIN" ]; then
    log_error "ghostty not found or not executable at $GHOSTTY_BIN"
    return 1
  fi
  "$GHOSTTY_BIN" -e sh -c "nvim '$TARGET_FILE'" &
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  main "$@"
fi
