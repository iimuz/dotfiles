#!/bin/sh
#
# Install gpg

# install gpg
sudo -E apt install -y --no-install-recommends \
  gnupg \
  gnupg-agent \
  gpgsm

