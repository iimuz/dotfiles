#!/bin/sh
#
# Install yarn
# See: https://yarnpkg.com/lang/en/docs/install/#debian-stable

curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -
echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list

sudo -E apt update
sudo -E apt install -y yarn

