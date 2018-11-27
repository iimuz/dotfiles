#!/bin/sh
#
# Downloads myrica font.

TEMPDIR=myrica

# download myrica font
FILENAME=Myrica.zip
TTCFILE=Myrica.TTC
wget https://github.com/tomokuni/Myrica/raw/master/product/$FILENAME
unzip $FILENAME -d $TEMPDIR
mv $TEMPDIR/$TTCFILE ./
rm -r $TEMPDIR
rm $FILENAME

