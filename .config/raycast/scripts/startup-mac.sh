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
# x86_64 archの方を呼び出す方法がわからない。
brew update
brew upgrade
brew bundle --file ../../homebrew/Brewfile-mac cleanup --force
# 自動でアップロードする機能をもつパッケージについてもhomebrewでアップデートできる。
# ただし、homebrewの思想として自前でアップデート機能を持つものは自分で実施なので、基本は有効にしない。
# ref: <https://qiita.com/bonji/items/183160eab52919aaf93e>
# brew upgrade --cask --greedy
mise up
gh extension upgrade --all

open -a "Scroll Reverser" # マウスによるscrollの逆転

# password and vpn
# open -a Bitwarden # bitwardenの起動設定で対処
open -a "Cisco Secure Client"

# browser
# open -a "Google Chrome"
open -a "Microsoft Edge"
# open -a "Brave browser"
# open -a "firefox"

# communication tool
open -a "Slack"
open -a "OneDrive"
open -a "Microsoft Teams"
open -a "Microsoft Outlook"

# work tools
open -a "Ghostty"
# open -a "Visual Studio Code"
open -a "Rancher Desktop"
