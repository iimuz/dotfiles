#!/bin/sh
#
# Install lazygit
# URL: https://github.com/jesseduffield/lazygit

VERSION=0.11.3
ARCH=Linux_x86_64
TEMP_DIR=./lazygit_expand
USER_LOCAL=~/.local/bin

FILENAME=lazygit_${VERSION}_${ARCH}.tar.gz
URL=https://github.com/jesseduffield/lazygit/releases/download/v${VERSION}/$FILENAME

# download lazygit
wget $URL

# expand and move
mkdir -p $TEMP_DIR
tar xaf $FILENAME -C $TEMP_DIR
mv $TEMP_DIR/lazygit $USER_LOCAL/
rm -r $TEMP_DIR $FILENAME

