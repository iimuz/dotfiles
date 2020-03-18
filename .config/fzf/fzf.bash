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

# Open the selected file with the default editor
# Ref: https://github.com/junegunn/fzf/wiki/examples#opening-files
fo() (
  IFS=$'\n' out=("$(fzf-tmux --query="$1" --exit-0 --expect=ctrl-o,ctrl-e)")
  key=$(head -1 <<< "$out")
  file=$(head -2 <<< "$out" | tail -1)
  if [ -n "$file" ]; then
    [ "$key" = ctrl-o ] && open "$file" || ${EDITOR:-vim} "$file"
  fi
)

# using ripgrep combined with preview
# find-in-file - usage: fif <searchTerm>
# Ref: https://github.com/junegunn/fzf/wiki/examples#searching-file-contents
fif() {
  if [ ! "$#" -gt 0 ]; then echo "Need a string to search for!"; return 1; fi
  rg --files-with-matches --no-messages "$1" | fzf --preview "highlight -O ansi -l {} 2> /dev/null | rg --colors 'match:bg:yellow' --ignore-case --pretty --context 10 '$1' || rg --ignore-case --pretty --context 10 '$1' {}"
}
