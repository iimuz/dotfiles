#!/usr/bin/env zsh

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Startup mac
# @raycast.mode fullOutput

# Optional parameters:
# @raycast.icon 🤖
# @raycast.packageName System

set -Eeuo pipefail

SCRIPT_DIR="$(cd "$(dirname "${0}")" >/dev/null 2>&1 && pwd)"

# brew
brew update
brew upgrade
BREWFILE="$SCRIPT_DIR/../../homebrew/Brewfile"
brew bundle cleanup --force --no-mas --file="$BREWFILE"
# Without --force, cleanup exits 1 when it only lists candidates or the prompt is declined.
brew bundle cleanup --mas --file="$BREWFILE" || true

# update mise
mise prune -y
mise cache clean -y
mise exec -- gh extension upgrade --all

# Open tools
# open -a "Cisco Secure Client"
# open -a "ghostty"
# open -a "Microsoft Edge"
