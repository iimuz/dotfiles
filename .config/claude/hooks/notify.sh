#!/usr/bin/env bash
# Claude Code notification hook for macOS using osascript.
# Usage: notify.sh <notification|stop>

set -u

# Run only on macOS with osascript available; otherwise do nothing.
command -v osascript >/dev/null 2>&1 || exit 0

# CMUX_SURFACE_ID only means "running inside a cmux terminal" and can be set
# even when cmux's own notification hooks are not actually active (e.g.
# CMUX_CLAUDE_HOOKS_DISABLED=1, or claude launched via a PATH entry that
# bypasses the cmux wrapper -- e.g. a mise-managed claude binary resolving
# before cmux's CLI shim). CMUX_CLAUDE_HOOK_CMUX_BIN is only exported by cmux
# within the hook-injection code path itself, so checking it means osascript
# is skipped only when cmux's notification hooks are genuinely handling the
# notification instead.
if [ -n "${CMUX_CLAUDE_HOOK_CMUX_BIN:-}" ]; then
  exit 0
fi

# herdr injects HERDR_ENV=1 into every managed pane and surfaces agent state
# (working/blocked/done) through its own toast notifications, so skip
# osascript inside herdr to avoid duplicate notifications.
if [ "${HERDR_ENV:-}" = "1" ]; then
  exit 0
fi

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
