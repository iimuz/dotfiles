#!/bin/sh
#
# Install gotop.
# URL: https://github.com/cjbassi/gotop

VERSION=3.0.0
ARCH=linux_amd64
TEMP_DIR=./gotop
USER_LOCAL=~/.local/bin

FILENAME=gotop_${VERSION}_${ARCH}.tgz
URL=https://github.com/cjbassi/gotop/releases/download/${VERSION}/$FILENAME

# download
wget $URL

# expand and move
mkdir -p $TEMP_DIR
tar xaf $FILENAME -C $TEMP_DIR
mv $TEMP_DIR/gotop $USER_LOCAL/
rm -r $TEMP_DIR $FILENAME

