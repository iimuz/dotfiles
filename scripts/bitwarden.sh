#!/bin/sh
#
# Install bitwarden CLI.

VERSION=1.22.1
ARCH=linux
USER_LOCAL=$HOME/.local/bin

expand_dir=bw-${ARCH}-$VERSION
archive_file=${expand_dir}.zip
download_url=https://github.com/bitwarden/cli/releases/download/v${VERSION}/$archive_file

# download bw
wget $download_url

# expand and replace
mkdir -p $expand_dir
unzip $archive_file -d $expand_dir
chmod u+x $expand_dir/bw
mv $expand_dir/bw $USER_LOCAL/
rm -r $expand_dir $archive_file

