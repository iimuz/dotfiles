#!/bin/bash
#
# Install fzf.
# URL: https://github.com/junegunn/fzf

set -eu

USER_LOCAL=$HOME/.local/bin
USER_CONFIG=$HOME/.config/fzf
GIT_REPOSITORY=https://github.com/junegunn/fzf.git
GIT_DIR=fzf

# clone git repository
git clone --depth 1 $GIT_REPOSITORY

# download binary
pushd $GIT_DIR
./install --bin --64
popd

# settings
if [ -f $USER_LOCAL/fzf ]; then rm $USER_LOCAL/fzf; fi
mv fzf/bin/fzf $USER_LOCAL/
if [ -f $USER_LOCAL/fzf-tmux ]; then rm $USER_LOCAL/fzf-tmux; fi
mv fzf/bin/fzf-tmux $USER_LOCAL/
mkdir -p $USER_CONFIG
cp fzf/shell/*.bash $USER_CONFIG/

# clean
rm -rf $GIT_DIR

