#!/usr/bin/env bash

set -Eeuo pipefail

script_name=$(basename "${0}")
readonly script_name
script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly script_dir

function log_info() {
  local _message="$1"
  echo "[$(date +'%Y-%m-%d %H:%M:%S')] [INFO] $_message" >&2
}

function log_err() {
  local _message="$1"
  echo "[$(date +'%Y-%m-%d %H:%M:%S')] [ERROR] $_message" >&2
}

function err() {
  log_err "Line $1: $2" >&2
  exit 1
}

trap 'err ${LINENO} "$BASH_COMMAND"' ERR

function usage() {
  cat <<EOF
Usage: ${script_name} [OPTIONS]

Post-installation script for devcontainer setup.
Configures dotfiles and Neovim plugins.

OPTIONS:
  -h, --help      Show this help message
  -v, --verbose   Enable verbose output

EXAMPLE:
  # Run post-installation setup
  $ ${script_name}
EOF
}

function setup_dotfiles() {
  log_info "Setting up dotfiles..."

  local -r repo_root="$(cd "$script_dir/.." && pwd)"

  (
    cd "$repo_root"
    mise trust
    bash setup_codespaces.sh
  )
  (
    # npm, uv 等の依存があるため 2 回実行が必要
    # (1 回目で npm/uv をインストールし、2 回目でそれらに依存するツールをインストール)
    cd
    mise trust
    mise install
    mise install
  )
}

function setup_nvim() {
  log_info "Setting up Neovim..."

  # Neovim plugin installation may fail in devcontainer provisioning (e.g., network
  # issues, missing dependencies). These failures are non-fatal.
  nvim --headless "+Lazy! sync" +qa || true
  nvim --headless "+MasonToolsInstallSync" +qa || true
  nvim --headless "+TSUpdateSync" +qa || true
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

  mise trust
  setup_dotfiles
  setup_nvim
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  main "$@"
fi
