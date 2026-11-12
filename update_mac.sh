#!/usr/bin/env bash
#
# Update packages and clean caches on macOS.
#
# Run from a terminal right after a reboot, before opening other apps: brew asks for
# sudo, and the processes that use the caches cleaned below are not running yet.

set -eu
set -o pipefail

STAMP_FILE="$HOME/.local/state/dotfiles/update-mac-weekly-cleanup"

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

# Weekly cleanup is keyed on the last success, not the calendar: the script is run by hand
# after reboots, so a fixed day would be missed, and a failed run must be retried next time.
weekly_cleanup_due() {
  local last
  if [ ! -f "$STAMP_FILE" ]; then
    return 0
  fi
  last=$(cat "$STAMP_FILE")
  if [[ ! "$last" =~ ^[0-9]+$ ]]; then
    return 0
  fi
  [ $(($(date +%s) - last)) -ge $((7 * 86400)) ]
}

# pnpm stores are deleted whole instead of pruned: pnpm here places files by clone, so
# `pnpm store prune` removes packages that existing projects still use.
clean_weekly() {
  rm -rf "$HOME/.local/share/pnpm/store" "$HOME/Library/pnpm/store" \
    "$HOME/.cache/pnpm" "$HOME/Library/Caches/pnpm"
  if [ -d "$HOME/go/pkg/mod" ]; then
    GOMODCACHE="$HOME/go/pkg/mod" go clean -modcache
  fi
  if [ -d "$HOME/.cache/uv" ]; then
    uv cache clean --cache-dir "$HOME/.cache/uv"
  fi
  for dir in "$HOME/.cache/npm-arm64" "$HOME/.npm"; do
    rm -rf "$dir/_cacache" "$dir/_npx"
  done
  for dir in "$HOME/.cache/mise" "$HOME/Library/Caches/mise"; do
    if [ -d "$dir" ]; then
      MISE_CACHE_DIR="$dir" mise cache clear
    fi
  done
  rm -rf "$HOME/Library/Caches/gopls" "$HOME/Library/Caches/goimports" \
    "$HOME/Library/Caches/node-gyp" "$HOME/Library/Caches/golangci-lint" \
    "$HOME/Library/Caches/dprint" "$HOME/.cache/pip"
}

record_weekly_cleanup() {
  mkdir -p "$(dirname "$STAMP_FILE")"
  date +%s >"$STAMP_FILE"
}

show_free_space before
update_tools
clean_every_run
# set -e does not apply inside a condition, so only the check is conditional
if weekly_cleanup_due; then
  clean_weekly
  record_weekly_cleanup
fi
show_free_space after
