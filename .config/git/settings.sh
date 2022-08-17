#!/bin/bash
#
# Setting for Git.

# Gurad if command does not exist.
if ! type git > /dev/null 2>&1; then return 0; fi

# Completion
if [ -f "$XDG_CONFIG_HOME/.git/git-completion.bash" ]; then
  source "$XDG_CONFIG_HOME/.git/git-completion.bash";
fi

