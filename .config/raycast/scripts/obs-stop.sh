#!/usr/bin/env zsh

# @raycast.schemaVersion 1
# @raycast.title OBS - Stop
# @raycast.mode silent
# @raycast.packageName Audio Tools
# @raycast.icon 🏁
# @raycast.argument1 { "type": "text", "placeholder": "移動先のフォルダ名" }

LOG_DIR="$HOME/.local/log/raycast"
mkdir -p "$LOG_DIR"
LOG_FILE="$LOG_DIR/obs-stop.log"

exec > >(tee -a "$LOG_FILE")
exec 2> >(tee -a "$LOG_FILE" >&2)
echo "=== $(date '+%Y-%m-%d %H:%M:%S') ==="

SCRIPT_DIR=
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" >/dev/null 2>&1 && pwd)"
readonly SCRIPT_DIR

SCRIPT_PATH="$SCRIPT_DIR/lib/obs-stop.py"

/opt/homebrew/bin/mise exec -- uv run "$SCRIPT_PATH" "$@"
