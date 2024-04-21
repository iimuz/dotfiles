#!/bin/bash
#
# Aliases for basic command.

alias ls='ls --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'

alias loadenv='env $(cat .env | xargs)'

if type eza > /dev/null 2>&1; then
  alias ll='eza -la'
elif tye exa > /dev/null 2>&1; then
  alias ll='exa -la'
else
  alias ll='ls -la'
fi
