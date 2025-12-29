#!/usr/bin/env bash
#
# Bitwarden GUI settings.

# Bitwarden GUI App が mac 環境でインストールされている事をチェック
if [ ! -d "/Applications/Bitwarden.app" ]; then return 0; fi

# Mac で AppStore からインストールした場合の sock の設定
export SSH_AUTH_SOCK=$HOME/Library/Containers/com.bitwarden.desktop/Data/.bitwarden-ssh-agent.sock
