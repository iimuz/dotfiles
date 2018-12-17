#!/bin/sh
#
# Downloads ricty font.

TEMPDIR=ricty

# download myrica font
VERSION=4.1.1
FILENAME=ricty_diminished-${VERSION}.tar.gz
TTCFILE=RictyDiminishedDiscord-Regular.ttf
wget https://www.rs.tus.ac.jp/yyusa/ricty_diminished/$FILENAME
mkdir -p $TEMPDIR
tar xvzf $FILENAME -C $TEMPDIR
mv $TEMPDIR/$TTCFILE ./
rm -r $TEMPDIR
rm $FILENAME

