#!/bin/bash
set -e

# reference: https://docs.docker.com/engine/install/ubuntu/

# uninstall docker
sudo apt-get remove docker docker-engine docker.io containerd runc

# sudo rm -rf /var/lib/docker
# sudo rm -rf /var/lib/containerd

# set up the repository
sudo apt-get update
sudo apt-get install \
   ca-certificates \
   curl \
   gnupg \
   lsb-release

sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# install Docker Engine
sudo apt-get update

#  apt-cache madison docker-ce
# sudo apt-get install docker-ce docker-ce-cli containerd.io
sudo apt-get install docker-ce=<VERSION_STRING> docker-ce-cli=<VERSION_STRING> containerd.io

# start docker
systemctl enable docker
systemctl restart docker
systemctl status docker
