#!/usr/bin/env bash
#
# homebrew bundleのための設定ファイル。
# - [homebrew bundle](https://github.com/Homebrew/homebrew-bundle)

# === Guard if command does not exist.
if ! type brew > /dev/null 2>&1; then return 0; fi

# === brew shellenv
eval "$(/opt/homebrew/bin/brew shellenv)"

# === current directory
current_directory="$(cd "$(dirname "${BASH_SOURCE[0]:-${(%):-%N}}")" && pwd)"

# === Brewfileの場所を設定
export HOMEBREW_BUNDLE_FILE="$current_directory/Brewfile-mac"
