#!/bin/sh
#
# Install procs command
# See: https://github.com/dalance/procs
# > A modern replacement for ps written in Rust

set -eu

VERSION=0.13.0
ARCH=x86_64
FILENAME=procs-v${VERSION}-${ARCH}-linux.zip

# download hugo
wget -q https://github.com/dalance/procs/releases/download/v${VERSION}/$FILENAME

unzip $FILENAME
mv procs ~/.local/bin/
rm -rf $FILENAME

echo "complete: procs"
