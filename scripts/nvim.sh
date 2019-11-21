#!/bin/sh
#
# Install neovim.

set -eu

NVIM_VERSION=0.4.3
USER_LOCAL=$HOME/.local

filename=nvim.appimage
curl -LO https://github.com/neovim/neovim/releases/download/v${NVIM_VERSION}/$filename
chmod u+x $filename
mv $filename $USER_LOCAL/bin/

