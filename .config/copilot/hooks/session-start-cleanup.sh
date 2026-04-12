#!/usr/bin/env bash
# sessionStart hook: clean up old log files.
#
# Deletes JSONL log files older than 30 days from the copilot hooks log directory.
set -eu

readonly LOG_BASE="${XDG_STATE_HOME:-$HOME/.local/state}/copilot/hooks"

if [ -d "$LOG_BASE" ]; then
  find "$LOG_BASE" -name '*.jsonl' -mtime +30 -delete 2>/dev/null || true
fi
