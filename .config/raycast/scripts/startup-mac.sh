#!/usr/bin/env zsh

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Startup mac
# @raycast.mode fullOutput

# Optional parameters:
# @raycast.icon 🤖
# @raycast.packageName System

set -Eeuo pipefail

# brew
brew update
brew upgrade
brew bundle --file ../../homebrew/Brewfile cleanup --force

# update mise
mise self-update -y
mise prune -y
mise cache clean -y
mise exec -- gh extension upgrade --all

# Open tools
open -a "Cisco Secure Client"
open -a "Ghostty"
open -a "Microsoft Edge"
