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

# === Brewfileの場所を設定
export HOMEBREW_BUNDLE_FILE="${_DOTFILES_CONFIG_DIR}/homebrew/Brewfile"
