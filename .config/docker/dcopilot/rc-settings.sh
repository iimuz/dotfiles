#!/usr/bin/env zsh

# スクリプトパスの特定
readonly local _DOTFILES_CONFIG_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-${(%):-%N}}")" && pwd)"

# shell設定
. "$_DOTFILES_CONFIG_DIR/bash/settings.sh"
. "$_DOTFILES_CONFIG_DIR/bash/aliases.sh"
. "$_DOTFILES_CONFIG_DIR/bash/command.sh"
. "$_DOTFILES_CONFIG_DIR/bash/path-settings.sh"
. "$_DOTFILES_CONFIG_DIR/bash/x11.sh"
. "$_DOTFILES_CONFIG_DIR/bash/xdg-base.sh"
if [ "$ZSH_VERSION" != "" ]; then . "$_DOTFILES_CONFIG_DIR/zsh/zsh-settings.sh"; fi

# application設定
. "$_DOTFILES_CONFIG_DIR/git/settings.sh"
. "$_DOTFILES_CONFIG_DIR/starship/starship-settings.sh"

# プログラミング言語設定
. "$_DOTFILES_CONFIG_DIR/mise/mise-settings.sh"
. "$_DOTFILES_CONFIG_DIR/go/go-settings.sh"
. "$_DOTFILES_CONFIG_DIR/node/npm.sh"
. "$_DOTFILES_CONFIG_DIR/python/pipx-settings.sh"

# copilot を mise でインストールしているので mise より後ろに設定が必要
. "$_DOTFILES_CONFIG_DIR/copilot/copilot.sh"

# 他の設定の影響を受けるので最後に実施
. "$_DOTFILES_CONFIG_DIR/bash/path-post-settings.sh"
