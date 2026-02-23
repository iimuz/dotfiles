#!/usr/bin/env bash

# @raycast.schemaVersion 1
# @raycast.title Daily Note - Add Selection
# @raycast.mode silent
# @raycast.icon 📥

set -Eeuo pipefail

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
  echo "no cleanup actions needed currently" >/dev/null
}

trap 'err ${LINENO} "$BASH_COMMAND"' ERR
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

  # AppleScriptを利用して `Cmd+C` をシミュレートし、クリップボードにコピー
  osascript -e 'tell application "System Events" to keystroke "c" using {command down}' -e 'delay 0.2'

  # 改行コードが適切に動作しない時があるので、 pbpaste を利用して選択箇所を取得
  local -r SELECTION=$(pbpaste)
  if [ -z "$SELECTION" ]; then
    log_warn "Nothing is selected"
    return 0
  fi

  # %s を使うことで、SELECTION内の特殊文字による意図しない挙動を防ぐ
  local -r TIMESTAMP="$(date +%Y-%m-%dT%H:%M:%S.000+09:00)"
  printf '\n## %s\n\n%s\n\n' "$TIMESTAMP" "$SELECTION" >>"$TARGET_FILE"

  log_info "Appended to $TARGET_DATE note"
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  main "$@"
fi
