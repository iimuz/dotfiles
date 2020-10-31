#!/bin/bash
#
# Node settings

# Gurad if command does not exist.
if ! type npm > /dev/null 2>&1; then return 0; fi

script_path="${BASH_SOURCE:-$0}"
if [ -L "$script_path" ]; then script_path=$(readlink -f "$script_path"); fi
readonly SCRIPT_DIR=$(cd $(dirname "$script_path"); pwd)

# Change default npm directory.
export NPM_CONFIG_USERCONFIG=$SCRIPT_DIR/npmrc
