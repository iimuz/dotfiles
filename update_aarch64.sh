#!/usr/bin/env bash
#
# Update packages.

set -eu
set -o pipefail

sudo apt update
sudo apt upgrade -y
sudo apt clean
sudo apt autoremove -y

if type gh > /dev/null 2>&1; then
  gh extension upgrade --all
fi

if type mise > /dev/null 2>&1; then
  mise up
  mise prune -y
  mise cache clean -y
fi

