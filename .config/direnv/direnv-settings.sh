#!/usr/bin/env bash
# direnv用の環境設定

# Gurad if command does not exist.
if ! type direnv > /dev/null 2>&1; then return 0; fi

# direnvの有効化
if [ -n "$ZSH_VERSION" ]; then
  # zshの場合
  eval "$(direnv hook zsh)"
else
  # bashの場合
  eval "$(direnv hook bash)"
fi


