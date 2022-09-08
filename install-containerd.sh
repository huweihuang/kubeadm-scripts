#!/bin/bash
set -e

ContainerdVersion=$1
ContainerdVersion=${ContainerdVersion:-1.6.6}

RuncVersion=$2
RuncVersion=${RuncVersion:-1.1.4}

CniVersion=$3
CniVersion=${CniVersion:-1.1.1}

NerdctlVersion=$4
NerdctlVersion=${NerdctlVersion:-0.21.0}

CrictlVersion=$5
CrictlVersion=${CrictlVersion:-1.24.2}

echo "--------------install containerd--------------"
wget https://github.com/containerd/containerd/releases/download/v${ContainerdVersion}/containerd-${ContainerdVersion}-linux-amd64.tar.gz
tar Cxzvf /usr/local containerd-${ContainerdVersion}-linux-amd64.tar.gz

echo "--------------install containerd service--------------"
wget https://raw.githubusercontent.com/containerd/containerd/681aaf68b7dcbe08a51c3372cbb8f813fb4466e0/containerd.service
mv containerd.service /lib/systemd/system/

mkdir -p /etc/containerd/
containerd config default > /etc/containerd/config.toml
sed -i 's/SystemdCgroup = false/SystemdCgroup = true/' /etc/containerd/config.toml

echo "--------------install runc--------------"
wget https://github.com/opencontainers/runc/releases/download/v${RuncVersion}/runc.amd64
chmod +x runc.amd64
mv runc.amd64 /usr/local/bin/runc

echo "--------------install cni plugins--------------"
wget https://github.com/containernetworking/plugins/releases/download/v${CniVersion}/cni-plugins-linux-amd64-v${CniVersion}.tgz
rm -fr /opt/cni/bin
mkdir -p /opt/cni/bin
tar Cxzvf /opt/cni/bin cni-plugins-linux-amd64-v${CniVersion}.tgz

echo "--------------install nerdctl--------------"
wget https://github.com/containerd/nerdctl/releases/download/v${NerdctlVersion}/nerdctl-${NerdctlVersion}-linux-amd64.tar.gz
tar Cxzvf /usr/local/bin nerdctl-${NerdctlVersion}-linux-amd64.tar.gz

echo "--------------install crictl--------------"
wget https://github.com/kubernetes-sigs/cri-tools/releases/download/v${CrictlVersion}/crictl-v${CrictlVersion}-linux-amd64.tar.gz
tar Cxzvf /usr/local/bin crictl-v${CrictlVersion}-linux-amd64.tar.gz

cat > /etc/crictl.yaml << \EOF
runtime-endpoint: unix:///run/containerd/containerd.sock
image-endpoint: unix:///run/containerd/containerd.sock
timeout: 2
debug: false
pull-image-on-create: false
EOF

# 启动containerd服务
systemctl daemon-reload
systemctl enable containerd
systemctl restart contaienrd