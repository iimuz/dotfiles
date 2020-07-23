#!/bin/bash
#
# Aliases for basic command.

alias ls='ls --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'

alias loadenv='env $(cat .env | xargs)'
