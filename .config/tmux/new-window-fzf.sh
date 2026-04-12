#!/usr/bin/env bash
#
# Create a new tmux window at a directory selected via fzf.
# Optionally set a custom window name.
# Intended to be called from tmux display-popup.

set -eu

selected_dir=$(find "${SOURCE_ROOT:-$HOME/src}" -follow \
  -maxdepth "${FFGHQ_MAXDEPTH:-3}" \
  -mindepth "${FFGHQ_MINDEPTH:-3}" \
  -type d | fzf)

if [ -z "$selected_dir" ]; then
  exit 0
fi

printf "Window name (empty for default): "
read -r window_name

if [ -n "$window_name" ]; then
  tmux new-window -n "$window_name" -c "$selected_dir"
else
  tmux new-window -c "$selected_dir"
fi
