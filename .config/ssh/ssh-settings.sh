#!/usr/bin/env bash
#
# ssh settings

if type keychain >/dev/null 2>&1; then
  eval "$(keychain --eval --agents ssh --quick)"
fi
