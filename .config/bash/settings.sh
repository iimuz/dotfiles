#!/bin/bash
#
# Common settings for bash.

# Set prompt color.
color_prompt=yes
force_color_prompt=yes

# Set bash_history setting.
export HISTCONTROL=ignoreboth:erasedups
if [[ "$SHELL" == *zsh* ]]; then
  setopt histappend
else
  shopt -u histappend
fi
save_history="history -n; history -w; history -c; history -r"
if [[ ";$PROMPT_COMMAND;" != *";$save_history;"* ]]; then
  export PROMPT_COMMAND="$save_history; $PROMPT_COMMAND"
fi

# Set DOTFILES variables.
export DOTFILES=$(cd $(dirname ${BASH_SOURCE:-$0})/../..; pwd)
