#!/bin/bash
set -ex

# 确保已经安装了helm工具
helm repo add cilium https://helm.cilium.io/
helm repo update

# 部署cilium
kubectl create ns cilium-system || true
helm install cilium cilium/cilium --namespace cilium-system \
    --set ipam.mode=cluster-pool \
    --set ipam.operator.clusterPoolIPv4CIDR="10.244.0.0/16" \
    --set ipam.operator.clusterPoolIPv4MaskSize=24

# 安装cilium cli
curl -L --remote-name https://github.com/cilium/cilium-cli/releases/latest/download/cilium-linux-amd64.tar.gz
tar xzvf cilium-linux-amd64.tar.gz
sudo mv cilium /usr/local/bin
cilium version
