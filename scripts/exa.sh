#!/bin/sh
#
# Install exa command
# See: https://github.com/ogham/exa/

VERSION=0.10.1
ARCH=x86_64
FILENAME=exa-linux-${ARCH}-${VERSION}.zip

# download hugo
wget -q https://github.com/ogham/exa/releases/download/v${VERSION}/$FILENAME
unzip $FILENAME
mv exa-linux-$ARCH ~/.local/bin/exa
rm -rf $FILENAME

echo "complelete: exa"
