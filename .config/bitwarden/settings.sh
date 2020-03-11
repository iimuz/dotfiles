#!/bin/bash
#
# Setting for Bitwarden.

# Gurad if command does not exist.
if ! type bw > /dev/null 2>&1; then return 0; fi

# Aliases
alias bw-unlock="export BW_SESSION=\$(bw unlock --raw)"

