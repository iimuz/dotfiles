#!/bin/sh
#
# Install ripgrep.
# https://github.com/BurntSushi/ripgrep

VERSION=11.0.2
DIR_NAME=ripgrep-${VERSION}-x86_64-unknown-linux-musl
FILENAME=${DIR_NAME}.tar.gz
URL=https://github.com/BurntSushi/ripgrep/releases/download/${VERSION}/${FILENAME}

LOCAL_DIR=$HOME/.local/bin
TEMP_DIR=./ripgrep_temp

wget $URL

mkdir -p $TEMP_DIR
tar xvzf $FILENAME -C $TEMP_DIR
mv $TEMP_DIR/$DIR_NAME/rg $LOCAL_DIR/
rm -rf $TEMP_DIR $FILENAME

