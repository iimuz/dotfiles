#!/bin/bash
#
# Install python at local space.

set -eu

PYTHON_VERSION=3.7.5
TCL_VERSION=8.6.6
TK_VERSION=8.6.6

USER_LOCAL=$HOME/.local

# install tcl
expand_dir=tcl$TCL_VERSION
archive_file=${expand_dir}.tar.gz
wget https://sourceforge.net/projects/tcl/files/${archive_file}/download -O $archive_file
tar xzvf $archive_file
mkdir $expand_dir/build && pushd $_
../unix/configure --prefix=$USER_LOCAL
make
make install
popd
rm -r $expand_dir
rm $archive_file

# install tk
expand_dir=tk$TK_VERSION
archive_file=${expand_dir}.tar.gz
wget https://sourceforge.net/projects/tcl/files/${archive_file}/download -O $archive_file
tar xzvf $archive_file
mkdir $expand_dir/build && pushd $_
../unix/configure --prefix=$USER_LOCAL
make
make install
popd
rm -r $expand_dir
rm $archive_file

# install python
$expand_dir=Python-$PYTHON_VERSION
$archive_file=${expand_dir}.tar.xz
wget https://www.python.org/ftp/python/${PYTHON_VERSION}/$archive_file
tar xfv $archive_file
mkdir $expand_dir/build && pushd $_
../configure \
  --prefix=$USER_LOCAL \
  --with-tcltk-includes="-I/$USER_LOCAL/include" \
  --with-tcltk-libs="-L/$USER_LOCAL/lib -ltcl8.6 -ltk8.6"
make
make install
popd
rm -r $expand_dir
rm $archive_file

# install pip
$py_file=get-pip.py
wget https://bootstrap.pypa.io/$py_file
$USER_LOCAL/bin/python3 $py_file
rm $py_file

