# find repositories under golang directory structure
alias ffghq='cd $(find ~/src -follow  -maxdepth 3 -mindepth 3 -type d | peco)'

# git
alias ffgb='`git branch | peco --prompt "GIT BRANCH>" | head -n 1 | sed -e "s/^\*\s*//g"`'

# history
export HISTCONTROL="ignoredups"
peco-history() {
  local NUM=$(history | wc -l)
  local FIRST=$((-1*(NUM-1)))

  if [ $FIRST -eq 0 ] ; then
    history -d $((HISTCMD-1))
    echo "No history" >&2
    return
  fi

  local CMD=$(fc -l $FIRST | sort -k 2 -k 1nr | uniq -f 1 | sort -nr | sed -E 's/^[0-9]+[[:blank:]]+//' | peco | head -n 1)

  if [ -n "$CMD" ] ; then
    history -s $CMD

    READLINE_LINE="${CMD}"
    READLINE_POINT=${#CMD}
  else
    history -d $((HISTCMD-1))
  fi
}
bind -x '"\C-r":peco-history'
