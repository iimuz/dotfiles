#!/usr/bin/env bash
#
# homebrew bundleのための設定ファイル。
# - [homebrew bundle](https://github.com/Homebrew/homebrew-bundle)

# === Guard if command does not exist.
if [ ! -x /opt/homebrew/bin/brew ]; then return 0; fi

# === brew shellenv
if [ -z "$HOMEBREW_PREFIX" ]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# === current directory
current_directory="$(cd "$(dirname "${BASH_SOURCE[0]:-${(%):-%N}}")" && pwd)"

# === Brewfileの場所を設定
export HOMEBREW_BUNDLE_FILE="$current_directory/Brewfile-mac"
