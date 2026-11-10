#!/usr/bin/env bash
#
# Update packages.

set -eu
set -o pipefail

sudo apt update
sudo apt upgrade -y
sudo apt clean
sudo apt autoremove -y

if type gh >/dev/null 2>&1; then
  gh extension upgrade --all
fi

if type mise >/dev/null 2>&1; then
  mise self-update -y
  mise install
  mise prune -y
  mise cache clean -y
fi

# deb は自動更新されないので最新の release を入れ直す
if type orca-ide >/dev/null 2>&1 && type gh >/dev/null 2>&1; then
  orca_deb=$(mktemp --suffix=.deb)
  gh release download -R stablyai/orca -p 'orca-ide_*_arm64.deb' -O "$orca_deb" --clobber
  sudo apt-get install -y "$orca_deb"
  rm -f "$orca_deb"
  # install 済みの skill だけが更新される
  orca-ide skills update --all
fi

if type claude >/dev/null 2>&1 && type playwright-cli >/dev/null 2>&1; then
  playwright-cli install --skills --global
  playwright-cli install-browser chromium --with-deps
fi
