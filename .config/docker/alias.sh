# docker を利用してコマンドを呼び出し、即時破棄する
function docker_command {
  image=$1
  command=$2
  docker run -it -v $(pwd):/src:rw -e USER_ID=$(id -u) -e GROUP_ID=$(id -g) $image $2 ${@:3}
}

# gcloud
alias dgconfig='docker run -it --name gcloud-config -e USER_ID=$(id -u) -e GROUP_ID=$(id -g) localhost:gcloud bash'
alias dgcloud='docker run --rm -it --volumes-from gcloud-config -v $(pwd):/src:rw -e USER_ID=$(id -u) -e GROUP_ID=$(id -g) localhost:gcloud gcloud'
alias dgcdel='dgcloud compute instances delete'
alias dgclist='dgcloud compute instances list'
alias dgcscp='dgcloud compute scp'
alias dgcssh='dgcloud compute ssh'
alias dgcstart='dgcloud compute instances start'
alias dgcstop='dgcloud compute instances stop'

# git
alias dgit='docker_command iimuz/git:v1.1.0-gpg1 git'
alias dgitexec='docker exec -it gitenv su-exec git ash'
alias dgitstart='docker start gitenv'

# hugo
alias dhugo='docker_command iimuz/hugo:v0.47.1-1 hugo'
alias dhugos='docker_command iimuz/hugo:v0.47.1-1 ash'

# neovim
alias dnvim='docker_command iimuz/neovim:v0.3.0-slim7 nvim'
alias dnvim-cpp='docker_command iimuz/neovim:v0.3.0-cpp7 nvim'
alias dnvim-go='docker_command iimuz/neovim:v0.3.0-golang1 nvim'
alias dnvim-js='docker_command iimuz/neovim:v0.3.0-node1 nvim'
alias dnvim-md='docker_command iimuz/neovim:v0.3.0-md7 nvim'
alias dnvim-py='docker_command iimuz/neovim:v0.3.0-py7 nvim'

# python
alias dpython='docker_command iimuz/python-dev:v3.7.0-pipenv1 python'

# travis
alias dtravis='docker_command iimuz/travis-client:v1.8.9 travis'

