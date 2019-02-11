#!/bin/sh
#
# Install ghq.

VERSION=0.8.0
ARCH=amd64
FILENAME=ghq_linux_${ARCH}.zip
UNZIP_DIR=ghq

SETTING_DIR=~/.config/git
SETTING_FILE=${SETTING_DIR}/local.config
GHQ_ROOT=~/src

# install prerequests
sudo -E apt install -y --no-install-recommends unzip

# download ghq
wget https://github.com/motemen/ghq/releases/download/v${VERSION}/${FILENAME}
unzip -d $UNZIP_DIR $FILENAME
sudo mv $UNZIP_DIR/ghq /usr/local/bin/
rm -rf $UNZIP_DIR $FILENAME

# settings
mkdir -p $SETTING_DIR
cat <<EOF >>$SETTING_FILE
[ghq]
  root = $GHQ_ROOT
EOF
