export HISTCONTROL=ignoreboth:erasedups
shopt -u histappend
export PROMPT_COMMAND="history -n; history -w; history -c; history -r; $PROMPT_COMMAND"

