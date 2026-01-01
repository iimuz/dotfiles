#!/usr/bin/env bash
#
# GnuPG Settings Script

# Guard if command does not exist.
if ! type gpg >/dev/null 2>&1; then return 0; fi

GPG_TTY=$(tty)
export GPG_TTY
