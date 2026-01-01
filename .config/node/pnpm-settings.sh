#!/usr/bin/env bash
#
# pnpm settings

if ! type pnpm &>/dev/null; then return; fi

export PNPM_HOME="$HOME/.local/share/pnpm"
case ":$PATH:" in
*":$PNPM_HOME:"*) ;;
*) export PATH="$PNPM_HOME:$PATH" ;;
esac
