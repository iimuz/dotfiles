#!/bin/sh
#
# Install git at user local space.

set -eu

GIT_VERSION=2.24.0
USER_LOCAL=~/.local

EXPAND_DIR=git-${GIT_VERSION}
ARCHIVE_FILE=${EXPAND_DIR}.tar.gz

wget https://mirrors.edge.kernel.org/pub/software/scm/git/$ARCHIVE_FILE
tar -zxf $ARCHIVE_FILE
pushd $EXPAND_DIR
make prefix=$USER_LOCAL all
make prefix=$USER_LOCAL install
popd

# clean
rm -r $EXPAND_DIR
rm $ARCHIVE_FILE

