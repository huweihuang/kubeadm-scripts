#!/bin/bash
set -ex

MasterDomain=$1
HostIP=$2

K8sVersion=$3
K8sVersion=${K8sVersion:-1.24.2}
NodeType="master"

bash install-all.sh ${NodeType} ${K8sVersion}

# 设置域名本地解析
echo "${HostIP} ${MasterDomain}" >> /etc/hosts

# 安装conntrack
apt -y install conntrack

# 下载kubeadm-config.yaml并修改MasterDomain和Version
wget https://raw.githubusercontent.com/huweihuang/kubeadm-scripts/main/kubeadm/kubeadm-config.yaml
sed -i "s|_MasterDomain_|${MasterDomain}|g;
s|_K8sVersion_|${K8sVersion}|g" kubeadm-config.yaml

# kubeadm init 创建第一个master节点
kubeadm init --config kubeadm-config.yaml --upload-certs  --node-name ${HostIP}
