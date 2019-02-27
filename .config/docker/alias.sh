# docker を利用してコマンドを呼び出し、即時破棄する
function docker_command {
  image=$1
  command=$2
  docker run --rm -it -v $(pwd):/src:rw -e USER_ID=$(id -u) -e GROUP_ID=$(id -g) $image $2 ${@:3}
}

# docker の shell を呼び出しコマンドを実行する
function docker_shell {
  image=$1
  shell=$2
  command="${@:3}"
  docker run -it -v $(pwd):/src:rw -e USER_ID=$(id -u) -e GROUP_ID=$(id -g) $image $shell -c "$command"
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
alias dgitsvn='docker_command iimuz/git:v1.1.0-svn1 git svn'

# hugo
alias dhugo='docker_command iimuz/hugo:v0.47.1-1 hugo'
alias dhugos='docker_shell iimuz/hugo:v0.47.1-1 ash'

# neovim
alias dnvim_command='docker run --rm -it -v $(pwd):/src:rw -w /src -u $(id -u):$(id -g)'
alias dnvim='dnvim_command iimuz/neovim:v0.3.1-slim1 nvim'
alias dnvim_cpp='dnvim_command iimuz/neovim:v0.3.1-cpp1 nvim'
alias dnvim_go='dnvim_command iimuz/neovim:v0.3.1-golang1 nvim'
alias dnvim_js='dnvim_command iimuz/neovim:v0.3.1-node1 nvim'
alias dnvim_md='dnvim_command iimuz/neovim:v0.3.1-md1 nvim'
alias dnvim_py='dnvim_command iimuz/neovim:v0.3.1-py1 nvim'

# python
alias dpython='docker_command iimuz/python-dev:v3.7.0-pipenv1 python'

# travis
alias dtravis='docker_command iimuz/travis-client:v1.8.9 travis'

