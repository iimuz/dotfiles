#!/usr/local/env bash
#
# asdfを利用したjava設定

# Gurad if command does not exist.
if ! type java > /dev/null 2>&1; then return 0; fi
if ! type asdf > /dev/null 2>&1; then return 0; fi

. "$ASDF_DATA_DIR/plugins/java/set-java-home.zsh"

