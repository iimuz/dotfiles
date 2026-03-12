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

function cleanup() {
  echo "no cleanup actions needed currently" >/dev/null
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

  if [ -f "$STATE_FILE" ]; then
    # ハンディON中 → 終了する
    # osascript -e 'tell application "System Events" to keystroke " " using {shift down, option down}'
    /Applications/Handy.app/Contents/MacOS/handy --toggle-post-process
    osascript -e "set volume input volume 0"
    rm "$STATE_FILE"
    log_info "🔇 音声入力を終了"
  else
    # ハンディOFF → 開始する
    osascript -e "set volume input volume 50"
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
