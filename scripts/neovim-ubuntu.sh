#!/bin/sh
#
# Install neovim
# Reference: https://github.com/neovim/neovim/wiki/Installing-Neovim

# to use ppa(Personal Package Archive)
sudo -E apt install -y --no-install-recommends software-properties-common
sudo -E apt-add-repository ppa:neovim-ppa/stable

# install neovim
sudo -E apt update
sudo -E apt install -y --no-install-recommends neovim
sudo -E apt install -y --no-install-recommends \
  python-dev \
  python-pip \
  python3-dev \
  python3-pip

# install neovim plugin for python
pip install --no-cache setuptools
pip install --no-cache neovim==0.3.1
pip3 install --no-cache setuptools
pip3 install --no-cache neovim==0.3.1

# install pt
PT_VERSION=2.2.0
PT_ARCH=amd64
PT_EXTDIR=pt_linux_${PT_ARCH}
PT_FILENAME=${PT_EXTDIR}.tar.gz
wget https://github.com/monochromegane/the_platinum_searcher/releases/download/v${PT_VERSION}/${PT_FILENAME}
tar xvzf $PT_FILENAME
sudo mv $PT_EXTDIR/pt /usr/local/bin/
rm -rf $PT_EXTDIR $PT_FILENAME

# install packages for c++
sudo -E apt install -y --no-install-recommends \
  ctags \
  global

