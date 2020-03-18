#!/bin/bash
#
# Setting for poetry.

poerty_bin="$HOME/.poetry/bin"
if [ -d "$poerty_bin" ]; then
  if [ "$poerty_bin" != *":$PATH:"* ]; then
    export PATH="$PATH:$poerty_bin"
  fi
fi
