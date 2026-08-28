#!/usr/bin/env zsh

# @raycast.schemaVersion 1
# @raycast.title OBS - Start
# @raycast.mode silent
# @raycast.packageName Audio Tools
# @raycast.icon 🔴

LOG_DIR="$HOME/.local/log/raycast"
mkdir -p "$LOG_DIR"
LOG_FILE="$LOG_DIR/obs-start.log"

exec > >(tee -a "$LOG_FILE")
exec 2> >(tee -a "$LOG_FILE" >&2)
echo "=== $(date '+%Y-%m-%d %H:%M:%S') ==="

SCRIPT_DIR="$(cd "$(dirname "${0}")" >/dev/null 2>&1 && pwd)"
readonly SCRIPT_DIR

SCRIPT_PATH="$SCRIPT_DIR/lib/obs-start.py"
if [ ! -f "$SCRIPT_PATH" ]; then
  echo "ERROR: $SCRIPT_PATH not found."
  exit 1
fi

/opt/homebrew/bin/mise exec -- uv run "$SCRIPT_PATH" "$@"
