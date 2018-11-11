# ghq
alias ffghq='cd $(ghq root)/$(ghq list | peco)'

# git
alias ffgb='`git branch | peco --prompt "GIT BRANCH>" | head -n 1 | sed -e "s/^\*\s*//g"`'

