#!/usr/bin/env bash
# Claude Code notification hook for macOS using osascript.
# Usage: notify.sh <notification|stop>

set -u

# Run only on macOS with osascript available; otherwise do nothing.
command -v osascript >/dev/null 2>&1 || exit 0

event="${1:-}"
case "$event" in
  notification)
    message="入力待ち"
    sound="Glass"
    ;;
  stop)
    message="作業完了"
    sound="Hero"
    ;;
  *)
    exit 0
    ;;
esac

# Repository (project) name.
repo="$(basename "${CLAUDE_PROJECT_DIR:-$PWD}")"

# Build subtitle with tmux context when available.
subtitle="$repo"
if [ -n "${TMUX:-}" ] && [ -n "${TMUX_PANE:-}" ]; then
  session="$(tmux display-message -t "$TMUX_PANE" -p '#{session_name}' 2>/dev/null || true)"
  window="$(tmux display-message -t "$TMUX_PANE" -p '#{window_name}' 2>/dev/null || true)"
  if [ -n "$session" ]; then
    subtitle="${session}:${window} (${repo})"
  fi
fi

# Strip double quotes to keep the AppleScript string well-formed.
subtitle="${subtitle//\"/}"

osascript -e "display notification \"${message}\" with title \"Claude Code\" subtitle \"${subtitle}\" sound name \"${sound}\"" >/dev/null 2>&1 || true

exit 0
