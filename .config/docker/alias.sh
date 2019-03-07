# docker を利用してコマンドを呼び出し、即時破棄する
function docker_command {
  image=$1
  command=$2
  docker run --rm -it -v $(pwd):/src:rw -e USER_ID=$(id -u) -e GROUP_ID=$(id -g) $image $2 ${@:3}
}

# 指定したファイルまたはディレクトリが見つかるまで親ディレクトリを探す
#
# 見つからない場合は、現在のディレクトリを指定するように返す
function search_parent_dir {
  current=$(pwd)
  target=$1
  max=10
  parent_dir='.'
  for ((i=0; i < $max; i++)); do
    if [ -e $current/$target ]; then
      break
    fi

    parent_dir=$(basename $current)/$parent_dir
    current=$(readlink -f $current/..)
  done
  if [ $i == $max ]; then
    current=$(pwd)
    parent_dir='.'
  fi

  echo "$current:$parent_dir"
}

# docker run with user setting
#
# 実行場所に .env がある場合は、該当するファイルを設定する。
function docker_run {
  envfile=$(pwd)/.env
  envsetting=''
  if [ -f $envfile ]; then
    envsetting="--env-file=$envfile"
  fi
  docker run --rm -it $envsetting -u $(id -u):$(id -g) $@
}

# docker run with mount current dir.
function docker_run_with_mount_current_dir {
  docker_run -v $(pwd):/src:rw -w /src $@
}

# docker run with mount finding specific dir.
#
# 第一引数でしていたファイルまたはディレクトリが見つかる場所をルートとして、
# /src 以下にマウントし、ワーキングディレクトリを実行パスに設定する。
function docker_run_with_mount_find_dir {
  target_dir=$1
  command=${@:2}

  old_ifs=$IFS
  IFS=':'
  set $(search_parent_dir $target_dir)
  mount_dir=$1
  work_dir=$2
  IFS=$old_ifs

  docker_run -v $mount_dir:/src:rw -w /src/$work_dir $command
}

# gcloud
alias gconfig='docker_run_with_mount_current_dir --name gcloud-config iimuz/gcloud:v237.0.0-1 bash'
alias gcloud='docker_run_with_mount_current_dir --volumes-from gcloud-config iimuz/gcloud:v237.0.0-1 gcloud'
alias gcdel='gcloud compute instances delete'
alias gclist='gcloud compute instances list'
alias gcscp='gcloud compute scp'
alias gcssh='gcloud compute ssh'
alias gcstart='gcloud compute instances start'
alias gcstop='gcloud compute instances stop'

# git
alias git='docker_run_with_mount_find_dir .git --volumes-from gpg_agent -v ~/.netrc.gpg:/.netrc.gpg:ro iimuz/git:v2.0.0-gpg1 git'
alias gits='docker_run_with_mount_find_dir .git --volumes-from gpg_agent -v ~/.netrc.gpg:/.netrc.gpg:ro iimuz/git:v2.0.0-gpg1 ash'
alias gitsvn='docker_run_with_mount_find_dir .git iimuz/git:v2.0.0-svn1 git svn'
alias gitsvns='docker_run_with_mount_find_dir .git iimuz/git:v2.0.0-svn1 git ash'

# gpg
alias gpg_agent='docker_run -d --name gpg_agent -v ~/.gnupg:/.gnupg:rw -v gpg_agent_sock:/run/user/$(id -u)/:ro iimuz/gnupg:v2.2.12-1 ash -c "gpg-connect-agent /bye"'
alias gpg_agents='docker_run --name gpg_agent -v ~/.gnupg:/.gnupg:rw -v gpg_agent_sock:/run/user/$(id -u)/:ro iimuz/gnupg:v2.2.12-1 ash'
alias gpg='docker_run_with_mount_current_dir --volumes-from gpg_agent iimuz/gnupg:v2.2.12-1 gpg --pinentry-mode loopback'
alias gpgs='docker_run_with_mount_current_dir --volumes-from gpg_agent iimuz/gnupg:v2.2.12-1 ash'

# hugo
alias hugo='docker_run_with_mount_current_dir iimuz/hugo:latest hugo'

# neovim
alias nvim='docker_run_with_mount_find_dir .git iimuz/neovim:v0.3.1-slim1 nvim'
alias nvim_cpp='docker_run_with_mount_find_dir .git iimuz/neovim:v0.3.1-cpp1 nvim'
alias nvim_go='docker_run_with_mount_find_dir .git iimuz/neovim:v0.3.1-golang1 nvim'
alias nvim_js='docker_run_with_mount_find_dir .git iimuz/neovim:v0.3.1-node1 nvim'
alias nvim_md='docker_run_with_mount_find_dir .git iimuz/neovim:v0.3.1-md1 nvim'
alias nvim_py='docker_run_with_mount_find_dir .git iimuz/neovim:v0.3.1-py1 nvim'

# python
alias python='docker_run_with_mount_current_dir iimuz/python-dev:v3.7.2-1 python'
alias pipenv='docker_run_with_mount_current_dir iimuz/python-dev:v3.7.2-1 pipenv'

# travis
alias travis='docker_command iimuz/travis-client:v1.8.9 travis'

