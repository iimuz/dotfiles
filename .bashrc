PS1="[\e[1;32m\]\u@\h:\w\[\e[m\]]\n$ "

# xdg base directory
export XDG_CACHE_HOME=~/.cache
export XDG_CONFIG_DIRS=/etc/xdg
export XDG_CONFIG_HOME=~/.config
export XDG_DATA_DIRS=/usr/local/share:/usr/share
export XDG_DATA_HOME=~/.local/share

alias ls='ls -G'

# fuzzy finder setting
## ghq
alias ffghq='cd $(ghq root)/$(ghq list | fzf)'
## git
alias ffgb='`git branch | fzf --prompt "GIT BRANCH>" | head -n 1 | sed -e "s/^\*\s*//g"`'
## docker
alias ffdps='docker ps --format "{{.ID}}\t{{.Image}}\t{{.Status}}\t{{.Command}}\t{{.RunningFor}}"'
alias ffexec='docker exec -it `ffdps | fzf | cut -f 1` $@'
alias ffdeb='ffexec /bin/bash'

