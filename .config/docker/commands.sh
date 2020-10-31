#!/bin/bash
#
# Command using docker.

# Gurad if command does not exist.
if ! type docker > /dev/null 2>&1; then return 0; fi

# Aliases.
# Run using current user id.
function _docker_run_command() {
  param_normal=""
  param_docker=""
  for OPT in "$@"
  do
    case "$OPT" in
      "--" | "-")
        shift 1
        param_docker="$param_docker $@"
        break
        ;;
      *)
        param_normal="$param_normal $1"
        shift 1
        ;;
    esac
  done

  envfile=$(pwd)/.env
  envsetting=""
  if [ -f "$envfile" ]; then envsetting="--env-file=$envfile"; fi

  echo "docker run --rm -t $envsetting -u $(id -u):$(id -g) $param_docker $param_normal"
}

function _docker_run() {
  eval $(_docker_run_command $@)
}

# Run using current user and mount current pwd.
function _docker_run_mount_current_dir_command() {
  workdir=$(pwd)
  echo "$(_docker_run_command --mount \"source=$(pwd),target=${workdir},type=bind,consistency=cached\" -w \"$workdir\" $@)"
}

function _docker_run_mount_current_dir() {
  eval "$(_docker_run_mount_current_dir_command $@)"
}

# Search for a specific folder from the parents folder.
function _search_parent_dir {
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

# Run using current user and mount specific folder.
function _docker_run_mount_specific_dir_command() {
  target_dir=$1
  command=${@:2}

  old_ifs=$IFS
  IFS=':'
  set $(_search_parent_dir $target_dir)
  mount_dir=$1
  work_dir=$2
  IFS=$old_ifs

  echo "$(_docker_run_command --mount \"source=${mount_dir},target=${mount_dir},type=bind,consistency=cached\" -w \"$mount_dir/$work_dir\" $command)"
}

function _docker_run_mount_specific_dir() {
  eval "$(_docker_run_mount_specific_dir_command $@)"
}

function _docker_run_mount_specific_dir_with_passwd_command() {
  target_dir=$1
  command=${@:2}

  old_ifs=$IFS
  IFS=':'
  set $(_search_parent_dir $target_dir)
  mount_dir=$1
  work_dir=$2
  IFS=$old_ifs

  echo "$(_docker_run_command --mount \"source=${mount_dir},target=${mount_dir},type=bind,consistency=cached\" -w \"$mount_dir/$work_dir\" -v /etc/passwd:/etc/passwd:ro -v /etc/group:/etc/group:ro $command)"
}

function _docker_run_mount_specific_dir_with_passwd() {
  eval "$(_docker_run_mount_specific_dir_with_passwd_command $@)"
}

# ディレクトリが存在する場合だけマウント用コマンドを返す.
function _get_mount_command() {
  r_base=${2:-"/home/dev"}

  mount_path="$1"
  h_mount="$HOME/$mount_path"
  r_mount="$r_base/$mount_path"

  mount_command=""
  if [ -d "$h_mount" ]; then
    mount_command="--mount source=${h_mount},target=${r_mount},type=bind,consistency=cached"
  fi

  echo "$mount_command"
}

# GCloud command.
function _docker_gcloud() {
  gcloud_config="$HOME/.config/gcloud"

  _docker_run_mount_current_dir \
    -e CLOUDSDK_CONFIG="$mygcloud" \
    --mount "source=${gcloud_config},target=/certs,type=bind,consistency=cached" \
    --mount "source=${gcloud_config}/mygcloud,target=/config/mygcloud,type=bind,consistency=cached" \
    $@
}

alias dfirebase="_docker_run_mount_current_dir $(_get_mount_command .config/configstore /home/node) iimuz/firebase:v7.3.1-1 firebase"
alias dgcloud="_docker_gcloud iimuz/gcloud:v262.0.0-1 gcloud"
alias dhugo="_docker_run_mount_current_dir iimuz/hugo:v0.63.1-1 hugo"
alias dnodec="_docker_run_mount_current_dir $(_get_mount_command .local/share/npm-global) iimuz/node:v13.6.0-1"
alias dnpm="_docker_run_mount_current_dir $(_get_mount_command .local/share/npm-global) iimuz/node:v13.6.0-1 npm"
alias dnvim="_docker_run_mount_specific_dir .git -it $(_get_mount_command .config/git/ignore) iimuz/neovim:v0.4.3-full4 nvim"
alias dnvim_cpp="_docker_run_mount_specific_dir .git $(_get_mount_command .config/git/ignore) iimuz/neovim:v0.4.3-cpp2 nvim"
alias dnvim_go="_docker_run_mount_specific_dir .git $(_get_mount_command .config/git/ignore) iimuz/neovim:v0.4.3-golang2 nvim"
alias dnvim_js="_docker_run_mount_specific_dir .git $(_get_mount_command .config/git/ignore) iimuz/neovim:v0.4.3-node3 nvim"
alias dnvim_slim="_docker_run_mount_specific_dir .git $(_get_mount_command .config/git/ignore) iimuz/neovim:v0.4.3-slim2 nvim"
alias dpipenv="_docker_run_mount_specific_dir .git iimuz/python:v3.7.5-1 pipenv"
alias dpipenvc="_docker_run_mount_specific_dir .git iimuz/python:v3.7.5-1"
alias dpoetry="_docker_run_mount_specific_dir .git iimuz/python:v3.7.5-1 poetry"
alias dpoetry-cuda="_docker_run_mount_specific_dir .git --gpus all iimuz/python:v3.7.5-cuda10.1-cudnn7-1 poetry"
alias dpoetry-all="_docker_run_mount_specific_dir_with_passwd .git --gpus all iimuz/python:v3.7.5-all2 poetry"
alias dpoetry-all-cuda="_docker_run_mount_specific_dir_with_passwd .git --gpus all iimuz/python:v3.7.5-all2 poetry"
alias dpsql="_docker_run_mount_current_dir postgres:12.2 psql"
alias dr="_docker_run_mount_current_dir $(_get_mount_command .local/share/renv) iimuz/r-base:v3.5.2 R"
alias dr-pipenv="_docker_run_mount_current_dir $(_get_mount_command .local/share/renv) iimuz/r-python:v3.5.2 pipenv"
alias dstack="_docker_run_mount_current_dir $(_get_mount_command .stack /) haskell:8.6.5 stack"
alias dtensorboard="_docker_run_mount_specific_dir .git tensorflow/tensorflow:2.1.0-py3 tensorboard"
alias dtravis="_docker_run_mount_current_dir iimuz/travis-client:v1.8.9 travis"

alias dcpoetry-all="_docker_run_mount_specific_dir_with_passwd_command .git --gpus all iimuz/python:v3.7.5-all2 poetry"
