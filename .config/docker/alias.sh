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

# docker run command with user
function docker_run {
  envfile=$(pwd)/.env
  envsetting=''
  if [ -f $envfile ]; then
    envsetting="--env-file=$envfile"
  fi
  docker run --rm -it $envsetting -v $(pwd):/src:rw -w /src -u $(id -u):$(id -g) $@
}

# gcloud
alias gconfig='docker_run --name gcloud-config iimuz/gcloud:v237.0.0-1 bash'
alias gcloud='docker_run --volumes-from gcloud-config iimuz/gcloud:v237.0.0-1 gcloud'
alias gcdel='gcloud compute instances delete'
alias gclist='gcloud compute instances list'
alias gcscp='gcloud compute scp'
alias gcssh='gcloud compute ssh'
alias gcstart='gcloud compute instances start'
alias gcstop='gcloud compute instances stop'

# git
alias git='docker_command iimuz/git:v1.1.0-gpg1 git'
alias gitexec='docker exec -it gitenv su-exec git ash'
alias gitstart='docker start gitenv'
alias gitsvn='docker_command iimuz/git:v1.1.0-svn1 git svn'

# hugo
alias hugo='docker_run iimuz/hugo:latest hugo'

# neovim
alias nvim='docker_run iimuz/neovim:v0.3.1-slim1 nvim'
alias nvim_cpp='docker_run iimuz/neovim:v0.3.1-cpp1 nvim'
alias nvim_go='docker_run iimuz/neovim:v0.3.1-golang1 nvim'
alias nvim_js='docker_run iimuz/neovim:v0.3.1-node1 nvim'
alias nvim_md='docker_run iimuz/neovim:v0.3.1-md1 nvim'
alias nvim_py='docker_run iimuz/neovim:v0.3.1-py1 nvim'

# python
alias python='docker_run iimuz/python-dev:v3.7.2-1 python'
alias pipenv='docker_run iimuz/python-dev:v3.7.2-1 pipenv'

# travis
alias travis='docker_command iimuz/travis-client:v1.8.9 travis'

