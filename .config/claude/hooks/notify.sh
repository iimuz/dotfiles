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

# Orca receives completion and waiting events through its own Claude Code hooks
# and shows its own notifications, so skip osascript to avoid duplicates. Those
# hooks reach Orca only when the hook port and a pane key (ORCA_PANE_KEY, or
# ORCA_AGENT_PANE as its fallback) are set, so check them rather than
# TERM_PROGRAM=Orca, which only says the shell runs in an Orca terminal.
if [ -n "${ORCA_AGENT_HOOK_PORT:-}" ] && [ -n "${ORCA_PANE_KEY:-${ORCA_AGENT_PANE:-}}" ]; then
  exit 0
fi

case "${CLAUDE_CODE_ENTRYPOINT:-}" in
  # Claude Desktop surfaces session state through its own notifications, so
  # skip osascript there to avoid duplicate notifications.
  claude-desktop) exit 0 ;;
  # Headless sessions (claude -p) have nobody waiting on them and the launcher
  # reports the overall outcome itself, so a notification at the end of every
  # session only piles up.
  sdk-cli) exit 0 ;;
esac

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

# Strip double quotes to keep the AppleScript string well-formed.
repo="${repo//\"/}"

osascript -e "display notification \"${message}\" with title \"Claude Code\" subtitle \"${repo}\" sound name \"${sound}\"" >/dev/null 2>&1 || true

exit 0
