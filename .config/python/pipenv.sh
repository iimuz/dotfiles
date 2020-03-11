#!/bin/bash
#
# Settings for python.

# Gurad if command does not exist.
if ! type pipenv > /dev/null 2>&1; then return 0; fi

export PIPENV_VENV_IN_PROJECT=true

