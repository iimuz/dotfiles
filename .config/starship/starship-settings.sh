#!/usr/bin/env bash
#
# starshipの設定ファイル。

# === Gurad if command does not exist.
if ! type starship > /dev/null 2>&1; then return 0; fi

if [[ "$SHELL" == *zsh* ]]; then
  eval "$(starship init zsh)"
else
  eval "$(starship init bash)"
fi

