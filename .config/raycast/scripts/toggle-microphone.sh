#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Toggle Microphone
# @raycast.mode silent

# Optional parameters:
# @raycast.icon 🤖
# @raycast.packageName System

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" >/dev/null 2>&1 && pwd)"

SWIFT_SRC="$SCRIPT_DIR/toggle-microphone.swift"
BIN="${XDG_CACHE_HOME:-$HOME/.cache}/raycast-scripts/toggle-microphone"

if [ ! -x "$BIN" ] || [ "$SWIFT_SRC" -nt "$BIN" ]; then
  mkdir -p "$(dirname "$BIN")"
  if ! swiftc -O -o "$BIN.tmp.$$" "$SWIFT_SRC"; then
    rm -f "$BIN.tmp.$$"
    exit 1
  fi
  mv -f "$BIN.tmp.$$" "$BIN"
fi

"$BIN" "$@"
