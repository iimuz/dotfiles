#!/bin/sh
#
# Install docui.
# URL: https://github.com/skanehira/docui/releases

VERSION=2.0.4
ARCH=Linux_x86_64
TEMP_DIR=./lazygit_expand
USER_LOCAL=~/.local/bin

FILENAME=docui_${VERSION}_${ARCH}.tar.gz
URL=https://github.com/skanehira/docui/releases/download/${VERSION}/$FILENAME

# download lazygit
wget $URL

# expand and move
mkdir -p $TEMP_DIR
tar xaf $FILENAME -C $TEMP_DIR
mv $TEMP_DIR/docui $USER_LOCAL/
rm -r $TEMP_DIR $FILENAME

