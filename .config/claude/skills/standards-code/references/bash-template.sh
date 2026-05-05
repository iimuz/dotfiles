#!/usr/bin/env bash
# [Short description]

set -Eeuo pipefail

SCRIPT_NAME=$(basename "${0}")
readonly SCRIPT_NAME

function log_info() {
  local message="$1"
  echo "[$(date +'%Y-%m-%d %H:%M:%S')] [$SCRIPT_NAME] [INFO] $message" >&2
}

function log_err() {
  local message="$1"
  echo "[$(date +'%Y-%m-%d %H:%M:%S')] [$SCRIPT_NAME] [ERROR] $message" >&2
}

function err() {
  log_err "Line $1: $2"
  exit 1
}

trap 'err ${LINENO} "$BASH_COMMAND"' ERR

function usage() {
  cat <<EOF
Usage: ${SCRIPT_NAME} [OPTIONS]

Description:
    [Short description]

OPTIONS:
    -h, --help      Show this help message
    -v, --verbose   Enable verbose output (set -x)

EXAMPLES:
    ${SCRIPT_NAME}
    ${SCRIPT_NAME} --verbose
    ${SCRIPT_NAME} --help
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
        log_err "Unknown option: $1"
        usage
        exit 1
        ;;
    esac
  done

  # Main logic here
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  main "$@"
fi
