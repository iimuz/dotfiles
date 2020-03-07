#!/bin/sh
#
# Install procs command
# See: https://github.com/dalance/procs
# > A modern replacement for ps written in Rust

VERSION=0.9.18
ARCH=x86_64
FILENAME=procs-v${VERSION}-${ARCH}-lnx.zip

# download hugo
wget https://github.com/dalance/procs/releases/download/v${VERSION}/$FILENAME

unzip $FILENAME
mv procs ~/.local/bin/
rm -rf $FILENAME
