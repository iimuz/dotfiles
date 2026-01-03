#!/usr/bin/env bash

# @raycast.schemaVersion 1
# @raycast.title Voice Recorder - Start Recording
# @raycast.mode silent
# @raycast.packageName Audio Tools
# @raycast.icon 🎙️

set -E -e -u -o pipefail

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

  # 設定
  local SCRIPT_DIR
  SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" >/dev/null 2>&1 && pwd)"
  readonly SCRIPT_DIR

  local -r PID_FILE="/tmp/voice_recorder.pid"
  local -r FILENAME_FILE="/tmp/voice_recorder_filename.txt"
  local -r FILENAME=$(date +"%Y-%m-%d_%H-%M-%S")

  # チェック
  if [ -f "$PID_FILE" ]; then
    log_error "Already recording."
    return 1
  fi

  # マイクをON
  osascript -e "set volume input volume 50"

  # Swiftスクリプトをバックグラウンドで実行
  nohup swift "$SCRIPT_DIR/voice-recorder-record.swift" "$FILENAME" >/dev/null 2>&1 &
  echo $! >"$PID_FILE"
  echo "rec_$FILENAME.m4a" >"$FILENAME_FILE"

  log_info "Recording started"
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  main "$@"
fi
