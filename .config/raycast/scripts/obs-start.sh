#!/usr/bin/env zsh

# @raycast.schemaVersion 1
# @raycast.title OBS - Start
# @raycast.mode silent
# @raycast.packageName Audio Tools
# @raycast.icon 🔴

source ~/.zshrc

local SCRIPT_DIR
SCRIPT_DIR="$(cd "$(dirname "${0}")" >/dev/null 2>&1 && pwd)"
readonly SCRIPT_DIR

local -r SCRIPT_PATH="$SCRIPT_DIR/obs-start.py"
if [ ! -f "$SCRIPT_PATH" ]; then
  log_error "$SCRIPT_PATH not found."
  return 1
fi

uv run "$SCRIPT_PATH" "$@"
