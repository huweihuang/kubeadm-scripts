#!/bin/bash
set -e

# reference: https://docs.docker.com/engine/install/ubuntu/

Version=${1:-1.6.8}

# uninstall docker
sudo apt-get remove docker docker-engine docker.io containerd runc

# sudo rm -rf /var/lib/docker
# sudo rm -rf /var/lib/containerd

# set up the repository
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

# install containerd
sudo apt-get update

sudo apt-get install -y containerd.io
# sudo apt-get install -y containerd.io=${Version}

systemctl daemon-reload
systemctl enable containerd
systemctl restart containerd
