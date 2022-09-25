#!/bin/bash
set -e

ContainerdVersion=$1
ContainerdVersion=${ContainerdVersion:-1.6.8}

echo "--------------clean containerd--------------"
mkdir /tmp/containerd/
mv /usr/bin/containerd* /tmp/containerd/
rm -fr /usr/local/bin/containerd* /usr/bin/containerd*

echo "--------------update containerd--------------"
wget https://github.com/containerd/containerd/releases/download/v${ContainerdVersion}/containerd-${ContainerdVersion}-linux-amd64.tar.gz
tar Cxzvf /usr containerd-${ContainerdVersion}-linux-amd64.tar.gz

echo "--------------check version--------------"
contaienrd --version

systemctl restart containerd
