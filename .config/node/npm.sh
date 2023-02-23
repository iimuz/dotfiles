#!/bin/bash
#
# Node settings

# === mac環境など別フォルダになる場合に既にPATHがある場合は削除
# guradより前に設置しないと切り替え先に存在しない場合に削除できない
if [ -n "$NPM_USER_PREFIX" ]; then
  remove_path "$NPM_USER_PREFIX/bin"
fi

# === Gurad if command does not exist.
if ! type npm > /dev/null 2>&1; then return 0; fi

# === npm configで保存場所をarm64/rosettaで変更するために環境変数を追加
# npmrcではif文による分岐ができないため、先に環境変数に条件分岐した値を設定する
# 先にデフォルト値を設定しておく
export NPM_USER_PREFIX=${XDG_DATA_HOME}/npm
export NPM_USER_CACHE=${XDG_CACHE_HOME}/npm
export NPM_USER_INIT=${XDG_CONFIG_HOM}/npm/config/npm-init.js
if [ "$(uname)" = "Darwin" ]; then  # MacOS
  # MacOSの場合のみarm64/rosettaを切り替える
  if [ "$(uname -m)" = "arm64" ]; then  # Apple silicon
    export NPM_USER_PREFIX=${XDG_DATA_HOME}/npm-arm64
    export NPM_USER_CACHE=${XDG_CACHE_HOME}/npm-arm64
    export NPM_USER_INIT=${XDG_CONFIG_HOME}/npm-arm64/config/npm-init.js
  else  # Intel
    export NPM_USER_PREFIX=${XDG_DATA_HOME}/npm-x64
    export NPM_USER_CACHE=${XDG_CACHE_HOME}/npm-x64
    export NPM_USER_INIT=${XDG_CONFIG_HOME}/npm-x64/config/npm-init.js
  fi
fi


# === npmrcを本スクリプトと同フォルダにあるnpmrcに設定
# $1: 実行するスクリプトパス ex. ${BASH_SOURCE:-$0}
function _change_default_npm_directory() {
  local script_path="$1"
  if [ -L "$script_path" ]; then script_path=$(readlink -f "$script_path"); fi
  local readonly script_path=$(cd $(dirname "$script_path"); pwd)

  # Change default npm directory.
  export NPM_CONFIG_USERCONFIG=$script_path/npmrc
}

_change_default_npm_directory "${BASH_SOURCE:-$0}"

#=== npmのglobalインストールの先をbinに追加
export PATH=$(npm config get prefix)/bin:$PATH
