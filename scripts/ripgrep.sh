#!/bin/sh
#
# Install ripgrep.
# https://github.com/BurntSushi/ripgrep

set -eu

VERSION=13.0.0
DIR_NAME=ripgrep-${VERSION}-x86_64-unknown-linux-musl
FILENAME=${DIR_NAME}.tar.gz
URL=https://github.com/BurntSushi/ripgrep/releases/download/${VERSION}/${FILENAME}

LOCAL_DIR=$HOME/.local/bin
TEMP_DIR=./ripgrep_temp

wget -q $URL

mkdir -p $TEMP_DIR
tar xzf $FILENAME -C $TEMP_DIR
mv $TEMP_DIR/$DIR_NAME/rg $LOCAL_DIR/
rm -rf $TEMP_DIR $FILENAME

echo "complete: ripgrep"
