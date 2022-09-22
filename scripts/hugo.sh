#!/bin/sh
#
# Install hugo

set -eu

VERSION=0.103.1
ARCH=64bit
FILENAME=hugo_extended_${VERSION}_Linux-${ARCH}.tar.gz
TEMP_DIR=./hugo_expand

# download hugo
wget -q https://github.com/gohugoio/hugo/releases/download/v${VERSION}/${FILENAME}

mkdir -p $TEMP_DIR
tar xzf $FILENAME -C $TEMP_DIR
mv $TEMP_DIR/hugo ~/.local/bin/
rm -rf $TEMP_DIR $FILENAME

echo "complete: hugo"
