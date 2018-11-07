#!/bin/sh
#
# Install gcloud

# スクリプトのパスを取得
cwd=`dirname "${0}"`
expr "${0}" : "/.*" > /dev/null || cwd=`(cd "${cwd}" && pwd)`

# 設定値
BASHRC_MAIN=~/.bashrc
BASHRC_DIR=~/.config/gcloud
BASH_SRC=`(cd "$cwd/../.config/gcloud" && pwd)`/alias.inc
BASHRC_GCLOUD=$BASHRC_DIR/`basename $BASH_SRC`

# install gcloud
curl https://sdk.cloud.google.com | bash

# set gloud bash setting
cat <<EOF >> $BASHRC_MAIN

# The next line enables shell alias command using gcloud.
if [ -f '${BASHRC_GCLOUD}' ]; then . '${BASHRC_GCLOUD}'; fi
EOF

mkdir -p $BASHRC_DIR
cd $BASHRC_DIR
ln -s $BASH_SRC

