#!/usr/bin/env bash
#
# Create a new tmux window at a directory selected via fzf.
# Optionally set a custom window name.
# Intended to be called from tmux display-popup.
#
# Requires: bash 5+, fzf, find, tmux

set -eu

# Source shell settings to ensure fzf and environment variables are available.
# tmux display-popup runs a non-interactive shell without rc file sourcing.
if [ -f "$HOME/.config/rc-settings.sh" ]; then
  . "$HOME/.config/rc-settings.sh"
fi

selected_dir=$(find "${SOURCE_ROOT:-$HOME/src}" -follow \
  -maxdepth "${FFGHQ_MAXDEPTH:-3}" \
  -mindepth "${FFGHQ_MINDEPTH:-3}" \
  -type d | fzf) || exit 0

printf "Window name (empty for default): "
read -r window_name

if [ -n "$window_name" ]; then
  tmux new-window -n "$window_name" -c "$selected_dir"
else
  tmux new-window -c "$selected_dir"
fi
