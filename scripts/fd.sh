#!/bin/sh
#
# Install fd command
# See: https://github.com/sharkdp/fd
# > A simple, fast and user-friendly alternative to 'find'

VERSION=7.4.0
ARCH=x86_64
FILENAME_STEM=fd-v${VERSION}-${ARCH}-unknown-linux-musl
FILENAME=${FILENAME_STEM}.tar.gz
TEMP_DIR=./fd_expand

# download hugo
wget https://github.com/sharkdp/fd/releases/download/v${VERSION}/$FILENAME

mkdir -p $TEMP_DIR
tar xvzf $FILENAME -C $TEMP_DIR
mv $TEMP_DIR/$FILENAME_STEM/fd ~/.local/bin/fd
rm -rf $TEMP_DIR $FILENAME
