#!/bin/bash
#
# Setting for X11.

if [[ "$(uname)" == "Linux" ]]; then
  export DISPLAY=localhost:0.0
fi

