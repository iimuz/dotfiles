# gcloud
alias dgconfig='docker run -it --name gcloud-config -e USER_ID=$(id -u) -e GROUP_ID=$(id -g) localhost:gcloud bash'
alias dgcloud='docker run --rm -it --volumes-from gcloud-config -v $(pwd):/src:rw -e USER_ID=$(id -u) -e GROUP_ID=$(id -g) localhost:gcloud gcloud'
alias dglist='dgcloud compute instances list'
alias dgscp='dgcloud compute scp'
alias dgssh='dgcloud compute ssh'
alias dgstart='dgcloud compute instances start'
alias dgstop='dgcloud compute instances stop'

# git
alias dgit='docker run --rm -it -v $(pwd):/src:rw -e USER_ID=$(id -u) -e GROUP_ID=$(id -g) iimuz/git:v1.1.0-gpg1'
alias dgitexec='docker exec -it gitenv su-exec git ash'
alias dgitstart='docker start gitenv'

# hugo
alias dhugo='docker run --rm -it -v $(pwd):/src:rw -e USER_ID=$(id -u) -e GROUP_ID=$(id -g) iimuz/hugo:v0.47.1-1'

# neovim
alias dnvim='docker run --rm -it -v $(pwd):/src:rw -e USER_ID=$(id -u) -e GROUP_ID=$(id -g) iimuz/neovim:v0.3.0-slim7'
alias dnvim-cpp='docker run --rm -it -v $(pwd):/src:rw -e USER_ID=$(id -u) -e GROUP_ID=$(id -g) iimuz/neovim:v0.3.0-cpp7'
alias dnvim-go='docker run --rm -it -v $(pwd):/src:rw -e USER_ID=$(id -u) -e GROUP_ID=$(id -g) iimuz/neovim:v0.3.0-golang1'
alias dnvim-js='docker run --rm -it -v $(pwd):/src:rw -e USER_ID=$(id -u) -e GROUP_ID=$(id -g) iimuz/neovim:v0.3.0-node1'
alias dnvim-md='docker run --rm -it -v $(pwd):/src:rw -e USER_ID=$(id -u) -e GROUP_ID=$(id -g) iimuz/neovim:v0.3.0-md7'
alias dnvim-py='docker run --rm -it -v $(pwd):/src:rw -e USER_ID=$(id -u) -e GROUP_ID=$(id -g) iimuz/neovim:v0.3.0-py7'

# python
alias dpython='docker run --rm -it -v $(pwd):/src:rw -e USER_ID=$(id -u) -e GROUP_ID=$(id -g) iimuz/python-dev:v3.7.0-pipenv1'

# travis
alias dtravis='docker run --rm -it -v $(pwd):/src:rw -e USER_ID=$(id -u) -e GROUP_ID$(id -g) iimuz/travis-client:v1.8.9 gosu dev bash'

