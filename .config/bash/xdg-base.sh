#!/bin/bash
#
# Setting for XDG BASE.

export XDG_CACHE_HOME=$HOME/.cache
export XDG_CONFIG_DIRS=/etc/xdg
export XDG_CONFIG_HOME=$HOME/.config
export XDG_DATA_DIRS=/usr/local/share:/usr/share:$XDG_DATA_DIRS
export XDG_DATA_HOME=$HOME/.local/share

local_bin=$HOME/.local/bin
if [ -d $local_bin ]; then
  if [[ ":$PATH:" != *":$local_bin:"* ]]; then
    export PATH=$local_bin:$PATH
  fi
fi

local_lib=$HOME/.local/share
if [ -d $local_lib ]; then
  if [[ ":$LD_LIBRARY_PATH:" != *":$local_lib:"* ]]; then
    export LD_LIBRARY_PATH=$local_lib:$LD_LIBRARY_PATH
  fi
fi

local_lib=$HOME/.local/lib
if [ -d $local_lib ]; then
  if [[ ":$LD_LIBRARY_PATH:" != *":$local_lib:"* ]]; then
    export LD_LIBRARY_PATH=$local_lib:$LD_LIBRARY_PATH
  fi
fi

