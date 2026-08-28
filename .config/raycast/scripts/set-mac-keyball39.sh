#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Set mac settings for keyball39.
# @raycast.mode silent

# Optional parameters:
# @raycast.icon 🤖
# @raycast.packageName System

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" >/dev/null 2>&1 && pwd)"

/Library/Application\ Support/org.pqrs/Karabiner-Elements/bin/karabiner_cli --select-profile="No settings"
"$SCRIPT_DIR/lib/set-volume.sh" 30
