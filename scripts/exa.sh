#!/bin/sh
#
# Install exa command
# See: https://github.com/ogham/exa/

VERSION=0.9.0
ARCH=x86_64
FILENAME=exa-linux-${ARCH}-${VERSION}.zip

# download hugo
wget https://github.com/ogham/exa/releases/download/v${VERSION}/$FILENAME

unzip $FILENAME
mv exa-linux-$ARCH ~/.local/bin/exa
rm -rf $FILENAME
