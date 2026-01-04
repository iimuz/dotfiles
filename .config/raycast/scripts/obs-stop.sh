#!/usr/bin/env zsh

# @raycast.schemaVersion 1
# @raycast.title OBS - Stop
# @raycast.mode silent
# @raycast.packageName Audio Tools
# @raycast.icon 🏁
# @raycast.argument1 { "type": "text", "placeholder": "移動先のフォルダ名" }

SCRIPT_DIR=
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" >/dev/null 2>&1 && pwd)"
readonly SCRIPT_DIR

SCRIPT_PATH="$SCRIPT_DIR/obs-stop.py"

source ~/.zshrc
uv run "$SCRIPT_PATH" "$@"
