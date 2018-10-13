# xdg base directory
if [ -f '~/.config/bash/xdg-base.sh' ]; then . '~/.config/bash/xdg-base.sh'; fi

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

