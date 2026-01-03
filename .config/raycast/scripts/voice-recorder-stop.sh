#!/usr/bin/env bash

# @raycast.schemaVersion 1
# @raycast.title Voice Recorder - Stop
# @raycast.mode silent
# @raycast.packageName Audio Tools
# @raycast.icon ⏹️

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
  echo "no cleanup actions needed currently" >/dev/null
}

trap 'err ${LINENO} "$BASH_COMMAND"' ERR
trap 'cleanup; exit 130' INT TERM
trap cleanup EXIT

function usage() {
  cat <<EOF
Usage: ${SCRIPT_NAME} [OPTIONS]

Stops the background audio recording and saves the recording file.

OPTIONS:
  -h, --help      Show this help message
  -v, --verbose   Enable verbose output

EXAMPLE:
  # Stop recording and append to daily note
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

  # 設定: `voice-recorder-start.sh` と合わせる必要がある
  local -r PID_FILE="/tmp/voice_recorder.pid"
  local -r FILENAME_FILE="/tmp/voice_recorder_filename.txt"

  # チェック
  if [ ! -f "$FILENAME_FILE" ]; then
    log_warn "No recording in progress"
    return 0
  fi

  # マイクをOFF
  osascript -e "set volume input volume 0"

  # Recording stop
  local -r PID=$(cat "$PID_FILE")
  kill "$PID"
  rm "$PID_FILE"
  rm "$FILENAME_FILE"

  log_info "Recording stopped & saved"
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  main "$@"
fi
