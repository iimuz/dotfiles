#!/usr/bin/env bash
#
# Claude settings.

# Gurad if command does not exist.
if ! type claude > /dev/null 2>&1; then return 0; fi

alias cgcommit='git commit -m "$(claude -p "/git-commit Look at the staged git changes and create a summarizing git commit title and message. Only respond with the title and message, and no affirmation.")"'

