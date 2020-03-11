#!/bin/bash
#
# Copy settings files from https://github.com/junegunn/fzf

# Gurad if command does not exist.
if ! type fzf > /dev/null 2>&1; then return 0; fi

FZF_CONFIG=$HOME/.config/fzf
FZF_COMPLETION=$FZF_CONFIG/completion.bash
FZF_KEYBINDINGS=$FZF_CONFIG/key-bindings.bash

# Use tmux for selecting window if tmux exists..
if type tmux > /dev/null 2>&1; then export FZF_TMUX=1; fi

# Use fzf completion.
if [ -f $FZF_COMPLETION ]; then . $FZF_COMPLETION 2> /dev/null; fi
# Use fzf keybindings.
if [ -f $FZF_KEYBINDINGS ]; then . $FZF_KEYBINDINGS; fi

# Aliases.
# Find repositories under golang directory structure
alias ffghq='cd $(find ${SOURCE_ROOT:-$HOME/src} -follow  -maxdepth 3 -mindepth 3 -type d | fzf)'

