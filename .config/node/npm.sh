#!/bin/bash
#
# Node settings

# Gurad if command does not exist.
if ! type npm > /dev/null 2>&1; then return 0; fi

# npmrcを本スクリプトと同フォルダにあるnpmrcに設定
# $1: 実行するスクリプトパス ex. ${BASH_SOURCE:-$0}
function _change_default_npm_directory() {
  local script_path="$1"
  if [ -L "$script_path" ]; then script_path=$(readlink -f "$script_path"); fi
  local readonly script_path=$(cd $(dirname "$script_path"); pwd)

  # Change default npm directory.
  export NPM_CONFIG_USERCONFIG=$script_path/npmrc
}

_change_default_npm_directory "${BASH_SOURCE:-$0}"

