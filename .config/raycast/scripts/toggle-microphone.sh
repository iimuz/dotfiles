#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Toggle Microphone
# @raycast.mode silent

# Optional parameters:
# @raycast.icon 🤖
# @raycast.packageName System

# 現在の入力ボリュームを取得
current_volume=$(osascript -e "input volume of (get volume settings)")

if [ "$current_volume" -eq 0 ]; then
  osascript -e "set volume input volume 50"
  echo "Unmute"
else
  osascript -e "set volume input volume 0"
  echo "Mute"
fi
