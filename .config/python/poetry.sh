#!/bin/bash
#
# Setting for poetry.

# Gurad if command does not exist.
if ! type poetry > /dev/null 2>&1; then return 0; fi

poerty_bin="$HOME/.poetry/bin"
if [ -d "$poerty_bin" ]; then
  if [ "$poerty_bin" != *":$PATH:"* ]; then
    export PATH="$PATH:$poerty_bin"
  fi
fi

