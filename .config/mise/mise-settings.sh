#!/usr/bin/env bash
#
# Mise settings
# see: <https//;github.c/mojdx/mise>

if ! type mise > /dev/null 2>&1; then return 0; fi

# eval "$($HOME/.local/bin/mise activate bash)"
eval "$(mise activate bash)"
