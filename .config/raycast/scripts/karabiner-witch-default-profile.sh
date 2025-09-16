#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Karabiner switch to default profile
# @raycast.mode silent

# Optional parameters:
# @raycast.icon 🤖
# @raycast.packageName System

/Library/Application\ Support/org.pqrs/Karabiner-Elements/bin/karabiner_cli --select-profile="Default profile"
