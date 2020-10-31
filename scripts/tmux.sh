#!/bin/sh
#
# Install tmux at local space.
#
# 追加作業として下記が必要になります。
#
# 1. 本スクリプトの実行後に Prefix + I キーでプラグインをインストール


LIBEVNET_VERSION=2.1.11
NCURSES_VERSION=6.2
TMUX_VERSION=3.1b
USER_LOCAL=$HOME/.local/
TMUX_PLUGINS_DIR=~/.tmux/plugins

# install libevent
expand_dir=libevent-${LIBEVNET_VERSION}-stable
archive_file=${expand_dir}.tar.gz
wget https://github.com/libevent/libevent/releases/download/release-${LIBEVNET_VERSION}-stable/$archive_file
tar zxvf $archive_file
pushd $expand_dir
./configure  --prefix=$USER_LOCAL
make
make install
popd
rm -r $expand_dir
rm $archive_file

# install ncurses
expand_dir=ncurses-${NCURSES_VERSION}
archive_file=${expand_dir}.tar.gz
wget http://ftp.gnu.org/gnu/ncurses/$archive_file
tar zxvf $archive_file
pushd $expand_dir
./configure  --prefix=$USER_LOCAL
make
make install
popd
rm -r $expand_dir
rm $archive_file

# install tmux
expand_dir=tmux-${TMUX_VERSION}
archive_file=${expand_dir}.tar.gz
wget https://github.com/tmux/tmux/releases/download/${TMUX_VERSION}/$archive_file
tar zxvf $archive_file
pushd $expand_dir
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$USER_LOCAL/lib
./configure --prefix=$USER_LOCAL CFLAGS="-I$USER_LOCAL/include" LDFLAGS="-L$USER_LOCAL/lib"
make
make install
popd
rm -r $expand_dir
rm $archive_file

# tmux のプラグインマネージャを設定
mkdir -p $TMUX_PLUGINS_DIR
pushd $TMUX_PLUGINS_DIR
git clone https://github.com/tmux-plugins/tpm
popd

