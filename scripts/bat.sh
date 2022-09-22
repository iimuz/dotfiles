#!/bin/sh
#
# Install bat command
# See: https://github.com/sharkdp/bat

set -eu

VERSION=0.22.1
ARCH=x86_64
FILENAME_STEM=bat-v${VERSION}-${ARCH}-unknown-linux-musl
FILENAME=${FILENAME_STEM}.tar.gz
TEMP_DIR=./bat_expand

# download hugo
wget -q https://github.com/sharkdp/bat/releases/download/v${VERSION}/$FILENAME

mkdir -p $TEMP_DIR
tar xvzf $FILENAME -C $TEMP_DIR
mv $TEMP_DIR/$FILENAME_STEM/bat ~/.local/bin/bat
rm -rf $TEMP_DIR $FILENAME

echo "complete: bat"
