#!/bin/sh
#
# Install hugo

VERSION=0.55.5
ARCH=64bit
FILENAME=hugo_${VERSION}_Linux-${ARCH}.tar.gz
TEMP_DIR=./hugo_expand

# download hugo
wget https://github.com/gohugoio/hugo/releases/download/v${VERSION}/${FILENAME}

mkdir -p $TEMP_DIR
tar xvzf hugo_${VERSION}_Linux-64bit.tar.gz -C $TEMP_DIR
mv $TEMP_DIR/hugo ~/.local/bin/
rm -rf $TEMP_DIR $FILENAME

