#!/bin/sh

# スクリプトのパスを取得
cwd=`dirname "${0}"`
expr "${0}" : "/.*" > /dev/null || cwd=`(cd "${cwd}" && pwd)`

# インストールする peco に関する設定
VERSION=0.5.3
ARCH=amd64
FILE_DIR=peco_linux_${ARCH}
FILENAME=${FILE_DIR}.tar.gz

# 設定ファイルの値
BASHRC_MAIN=~/.bashrc
BASHRC_SRC=`(cd "$cwd/../.config/peco" && pwd)`/alias.inc
BASHRC_DSTDIR=~/.config/peco
BASHRC_DST=$BASHRC_DSTDIR/`basename $BASHRC_SRC`

# download ghq
wget https://github.com/peco/peco/releases/download/v${VERSION}/${FILENAME}
tar xvzf $FILENAME
sudo mv $FILE_DIR/peco /usr/local/bin/
rm -rf $FILE_DIR $FILENAME

# settings
cat <<EOF >> $BASHRC_MAIN

# The next line enables shell alias command using peco.
if [ -f '${BASHRC_DST}' ]; then . '${BASHRC_DST}'; fi
EOF

mkdir -p $BASHRC_DSTDIR
ln -s $BASHRC_SRC $BASHRC_DST
