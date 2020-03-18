#!/bin/bash
#
# VSCode settings

# Gurad if command does not exist.
if ! type code > /dev/null 2>&1; then return 0; fi

# Change default editor
export EDITOR=code
