#!/bin/sh
#
# Install docker ce
# Reference: https://docs.docker.com/install/linux/docker-ce/ubuntu/#set-up-the-repository

DOCKER_COMPOSE_VERSION=1.26.2

# update the apk package index.
sudo -E apt update

# install packages to allow apt to use a repository over HTTPS.
sudo -E apt install -y --no-install-recommends \
  apt-transport-https \
  ca-certificates \
  curl \
  software-properties-common

# add Docker's official GPG key.
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

# set up the stable repository.
sudo add-apt-repository \
  "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) \
  stable"

# install docker ce.
sudo -E apt update
sudo -E apt install -y docker-ce

# to use docker as non-root user.
sudo usermod -aG docker $USER

# install docker-compose.
sudo -E curl -L "https://github.com/docker/compose/releases/download/${DOCKER_COMPOSE_VERSION}/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

