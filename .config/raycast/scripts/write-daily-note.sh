#!/usr/bin/env bash

# @raycast.schemaVersion 1
# @raycast.title Add Selection to Daily Note
# @raycast.mode silent
# @raycast.icon 📥

set -Eeuo pipefail

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
    return 1
  fi

  # %s を使うことで、SELECTION内の特殊文字による意図しない挙動を防ぐ
  printf "\n## $(date +%H:%M:%S)\n\n%s\n\n" "$SELECTION" >>"$TARGET_FILE"

  log_info "Appended to $TARGET_DATE note"
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  main "$@"
fi
