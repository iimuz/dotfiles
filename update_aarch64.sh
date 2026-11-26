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

# root が要る掃除は更新の後に置く。snapd の自動更新と重なって snap remove が失敗しても、ツールの更新を止めないため。
sudo journalctl --vacuum-size=500M

# 無効な snap の判定は Notes 列だけで行う。名前に disabled を含む snap を消さないため。
# 一覧を先に変数へ取り出すのは、snap list を読みながら同じ snap を消さないため。
if type snap >/dev/null 2>&1; then
  disabled_snaps=$(snap list --all | awk 'NR > 1 && $NF ~ /(^|,)disabled(,|$)/ { print $1, $3 }')
  while read -r name rev; do
    if [ -n "$name" ]; then
      sudo snap remove "$name" --revision="$rev"
    fi
  done <<<"$disabled_snaps"
fi
