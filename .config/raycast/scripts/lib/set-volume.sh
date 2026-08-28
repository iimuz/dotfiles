#!/bin/bash

if [ $# -ne 1 ]; then
  echo "Error: usage: set-volume.sh <0-100>"
  exit 1
fi

osascript -e "set volume output volume ${1}"
