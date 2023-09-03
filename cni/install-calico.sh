#!/bin/bash
set -ex

# 开通179的BGP TCP端口
#iptables -A INPUT -p tcp --dport 179 -j ACCEPT -m comment --comment calico-port

wget https://raw.githubusercontent.com/projectcalico/calico/master/manifests/calico.yaml

# 修改配置
sed -i 's/kube-system/calico-system/g' calico.yaml
# 修改pod cidr网段
sed -i 's/192.168.0.0\/16/10.244.0.0\/16/g' calico.yaml

# 安装calico
kubectl create ns calico-system || true
kubectl apply -f calico.yaml

# 安装calicoctl
wget https://github.com/projectcalico/calico/releases/latest/download/calicoctl-linux-amd64 -O /usr/local/bin/calicoctl && chmod +x /usr/local/bin/calicoctl
