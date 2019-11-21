#!/bin/sh
#
# Install the platinum searcher (pt).

VERSION=2.2.0
ARCH=amd64
FILENAME=pt_linux_${ARCH}.tar.gz
TEMP_DIR=./pt_expand

# download hugo
wget https://github.com/monochromegane/the_platinum_searcher/releases/download/v${VERSION}/${FILENAME}

mkdir -p $TEMP_DIR
tar xvzf $FILENAME -C $TEMP_DIR
mv $TEMP_DIR/pt_linux_amd64/pt ~/.local/bin/
rm -rf $TEMP_DIR $FILENAME


