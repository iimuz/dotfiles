# set bash_history setting
export HISTCONTROL=ignoreboth:erasedups
shopt -u histappend
save_history="history -n; history -w; history -c; history -r"
if [[ ";$PROMPT_COMMAND;" != *";$save_history;"* ]]; then
  export PROMPT_COMMAND="$save_history; $PROMPT_COMMAND"
fi

