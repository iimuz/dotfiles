#!/usr/bin/env bash

# スクリプトパスの特定
if [ "$ZSH_VERSION" != "" ]; then  # zshの場合
  readonly local _DOTFILES_CONFIG_DIR="$(cd "$(dirname "${(%):-%N}")" && pwd)"
else  # bashを想定
  readonly local _DOTFILES_CONFIG_DIR="$(cd "$(dirname "$BASH_SOURCE")" && pwd)"
fi

# shell設定
. "$_DOTFILES_CONFIG_DIR/bash/settings.sh"
. "$_DOTFILES_CONFIG_DIR/bash/aliases.sh"
. "$_DOTFILES_CONFIG_DIR/bash/command.sh"
. "$_DOTFILES_CONFIG_DIR/bash/path-settings.sh"
. "$_DOTFILES_CONFIG_DIR/bash/x11.sh"
. "$_DOTFILES_CONFIG_DIR/bash/xdg-base.sh"
if [ "$ZSH_VERSION" != "" ]; then . "$_DOTFILES_CONFIG_DIR/zsh/zsh-settings.sh"; fi

# homebrew設定
. "$_DOTFILES_CONFIG_DIR/homebrew/homebrew-bundle.sh"

# application設定
. "$_DOTFILES_CONFIG_DIR/bitwarden/settings.sh"
. "$_DOTFILES_CONFIG_DIR/docker/colima-settings.sh"
. "$_DOTFILES_CONFIG_DIR/fzf/fzf.bash"
. "$_DOTFILES_CONFIG_DIR/git/settings.sh"
. "$_DOTFILES_CONFIG_DIR/nvim/nvim-settings.sh"
. "$_DOTFILES_CONFIG_DIR/vscode/vscode.sh"
. "$_DOTFILES_CONFIG_DIR/xcode/xcode-settings.sh"

# プログラミング言語設定
# 環境構築
. "$_DOTFILES_CONFIG_DIR/asdf/asdf-settings.sh"
. "$_DOTFILES_CONFIG_DIR/direnv/direnv-settings.sh"
# go lang
. "$_DOTFILES_CONFIG_DIR/go/go-settings.sh"
# java
. "$_DOTFILES_CONFIG_DIR/java/java-asdf-settings.sh"
# nodejs
. "$_DOTFILES_CONFIG_DIR/node/nvm-settings.sh"
. "$_DOTFILES_CONFIG_DIR/node/npm.sh"
# python
. "$_DOTFILES_CONFIG_DIR/python/pipx-settings.sh"
. "$_DOTFILES_CONFIG_DIR/python/pyenv-settings.sh"
. "$_DOTFILES_CONFIG_DIR/python/poetry-settings.sh"
# ruby
. "$_DOTFILES_CONFIG_DIR/ruby/ruby-settings.sh"

# 他の設定の影響を受けるので最後に実施
. "$_DOTFILES_CONFIG_DIR/bash/path-post-settings.sh"
