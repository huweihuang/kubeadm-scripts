#!/bin/bash
set -ex

# kubeadm重置
kubeadm reset --force || true

# 清空数据目录
rm -fr /etc/kubernetes
rm -fr ~/.kube/

# 重置cni0网关
ifconfig cni0 down || true
ip link delete cni0 || true
