#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Set mac settings for default.
# @raycast.mode silent

# Optional parameters:
# @raycast.icon 🤖
# @raycast.packageName System

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" >/dev/null 2>&1 && pwd)"

"$SCRIPT_DIR/lib/set-brightness.sh" 0.5
"$SCRIPT_DIR/lib/set-volume.sh" 30
"$SCRIPT_DIR/toggle-microphone.sh" mute >/dev/null
