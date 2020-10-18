#!/bin/bash
#
# Node settings

# Gurad if command does not exist.
if ! type npm > /dev/null 2>&1; then return 0; fi

# Change default npm directory.
export PATH=$PATH:~/.npm-global/bin
