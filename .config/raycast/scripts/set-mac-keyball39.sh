#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Set mac settings for keyball39.
# @raycast.mode silent

# Optional parameters:
# @raycast.icon 🤖
# @raycast.packageName System

/Library/Application\ Support/org.pqrs/Karabiner-Elements/bin/karabiner_cli --select-profile="No settings"
osascript -e "set volume output volume 40"
