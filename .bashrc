PS1="[\e[1;32m\]\u@\h:\w\[\e[m\]]\n$ "

# xdg base directory
export XDG_CACHE_HOME=~/.cache
export XDG_CONFIG_DIRS=/etc/xdg
export XDG_CONFIG_HOME=~/.config
export XDG_DATA_DIRS=/usr/local/share:/usr/share
export XDG_DATA_HOME=~/.local/share

alias ls='ls -G'

# peco ghq
alias peco-ghq='cd $(ghq root)/$(ghq list | peco)'
# peco git branch
alias peco-gb='`git branch | peco --prompt "GIT BRANCH>" | head -n 1 | sed -e "s/^\*\s*//g"`'
# peco docker
alias peco-dps='docker ps --format "{{.ID}}\t{{.Image}}\t{{.Status}}\t{{.Command}}\t{{.RunningFor}}"'
alias peco-deb='docker exec -it `dps | peco | cut -f 1` /bin/bash'

# peco histroy
export HISTCONTROL="ignoredups"
peco-history() {
  local NUM=$(history | wc -l)
  local FIRST=$((-1*(NUM-1)))

  if [ $FIRST -eq 0 ] ; then
    # Remove the last entry, "peco-history"
    history -d $((HISTCMD-1))
    echo "No history" >&2
    return
  fi

  local CMD=$(fc -l $FIRST | sort -k 2 -k 1nr | uniq -f 1 | sort -nr | sed -E 's/^[0-9]+[[:blank:]]+//' | peco | head -n 1)
  READLINE_LINE=${CMD}
  READLINE_POINT=${#CMD}

  if [ -n "$CMD" ] ; then
    # Replace the last entry, "peco-history", with $CMD
    history -s $CMD

    if type osascript > /dev/null 2>&1 ; then
      # Send UP keystroke to console
      (osascript -e 'tell application "System Events" to keystroke (ASCII character 30)' &)
    fi
  else
    # Remove the last entry, "peco-history"
    history -d $((HISTCMD-1))
  fi
}
bind -x '"\C-r":"peco-history"'
