#!/bin/bash
#
# Command using docker.

# Gurad if command does not exist.
if ! type python > /dev/null 2>&1; then return 0; fi

# Aliases.
# Run using current user id.
function _docker_run() {
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

  docker run --rm -it $envsetting -u $(id -u):$(id -g) $param_docker $param_normal
}

# Run using current user and mount current pwd.
function _docker_run_mount_current_dir() {
  workdir="/workspace"
  _docker_run \
    --mount "source=$(pwd),target=${workdir},type=bind,consistency=cached" \
    -w "$workdir" \
    $@
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
function _docker_run_mount_specific_dir() {
  target_dir=$1
  command=${@:2}

  old_ifs=$IFS
  IFS=':'
  set $(_search_parent_dir $target_dir)
  mount_dir=$1
  work_dir=$2
  IFS=$old_ifs

  work_base="/workspace"
  _docker_run \
    --mount "source=${mount_dir},target=${wark_base},type=bind,consistency=cached" \
    -w "$work_base/$work_dir" \
    $command
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

  return $mount_command
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
alias dnvim="_docker_run_mount_specific_dir .git $(_get_mount_command .config/git/ignore) iimuz/neovim:v0.4.3-full4 nvim"
alias dnvim_cpp="_docker_run_mount_specific_dir .git $(_get_mount_command .config/git/ignore) iimuz/neovim:v0.4.3-cpp2 nvim"
alias dnvim_go="_docker_run_mount_specific_dir .git $(_get_mount_command .config/git/ignore) iimuz/neovim:v0.4.3-golang2 nvim"
alias dnvim_js="_docker_run_mount_specific_dir .git $(_get_mount_command .config/git/ignore) iimuz/neovim:v0.4.3-node3 nvim"
alias dnvim_slim="_docker_run_mount_specific_dir .git $(_get_mount_command .config/git/ignore) iimuz/neovim:v0.4.3-slim2 nvim"
alias dpipenv="_docker_run_mount_specific_dir .git iimuz/python:v3.7.5-1 pipenv"
alias dpipenvc="_docker_run_mount_specific_dir .git iimuz/python:v3.7.5-1"
alias dpoetry="_docker_run_mount_specific_dir .git iimuz/python:v3.7.5-1 poetry"
alias dpoetry="_docker_run_mount_specific_dir .git --gpus all iimuz/python:v3.7.5-cuda10.1-cudnn7-1 poetry"
alias dpsql="_docker_run_mount_current_dir postgres:12.2 psql"
alias dpoetry="_docker_run_mount_current_dir iimuz/python:v3.7.5-1 python"
alias dr="_docker_run_mount_current_dir $(_get_mount_command .local/share/renv) iimuz/r-base:v3.5.2 R"
alias dr-pipenv="_docker_run_mount_current_dir $(_get_mount_command .local/share/renv) iimuz/r-python:v3.5.2 pipenv"
alias dstack="_docker_run_mount_current_dir $(_get_mount_command .stack /) haskell:8.6.5 stack"
alias dtensorboard="_docker_run_mount_specific_dir .git tensorflow/tensorflow:2.1.0-py3 tensorboard"
alias dtravis="_docker_run_mount_current_dir iimuz/travis-client:v1.8.9 travis"

