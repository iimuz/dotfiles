#!/usr/bin/env bash
#
# Update packages and clean caches on macOS.
#
# Run from a terminal right after a reboot, before opening other apps: brew asks for
# sudo, and the processes that use the caches cleaned below are not running yet.

set -eu
set -o pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"

show_free_space() {
  echo "Free space $1:"
  df -h "$HOME"
}

update_tools() {
  brew update
  brew upgrade
  # Keep --no-mas: the Brewfile lists no App Store apps, so --force would uninstall all of them whenever mas is present.
  brew bundle cleanup --force --no-mas --file="$SCRIPT_DIR/.config/homebrew/Brewfile"
  mise exec -- gh extension upgrade --all
}

# Targets are named under $HOME instead of read from XDG_* or tool settings: the terminal's
# values can point at other locations, and both the terminal and non-terminal locations must be cleaned.
clean_every_run() {
  mise prune -y
  if [ -d "$HOME/.cache/uv" ]; then
    uv cache prune --cache-dir "$HOME/.cache/uv"
  fi
  # npm creates the cache directory when it is missing
  for dir in "$HOME/.cache/npm-arm64" "$HOME/.npm"; do
    if [ -d "$dir" ]; then
      npm cache verify --cache "$dir"
    fi
  done
}

show_free_space before
update_tools
clean_every_run
show_free_space after
