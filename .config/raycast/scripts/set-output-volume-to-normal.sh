#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Set output volume to normal
# @raycast.mode silent

# Optional parameters:
# @raycast.icon 🤖
# @raycast.packageName System

osascript -e "set volume output volume 40"
