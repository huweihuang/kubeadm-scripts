#!/bin/bash
set -e

ContainerdVersion=$1
ContainerdVersion=${ContainerdVersion:-1.6.8}

echo "--------------update containerd--------------"
wget https://github.com/containerd/containerd/releases/download/v${ContainerdVersion}/containerd-${ContainerdVersion}-linux-amd64.tar.gz
tar Cxzvf /usr/local containerd-${ContainerdVersion}-linux-amd64.tar.gz

echo "--------------check version--------------"
contaienrd --version

systemctl restart containerd
