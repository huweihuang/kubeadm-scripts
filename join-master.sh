#!/bin/bash
set -ex

MasterDomain=$1
MasterIP=$2
NodeName=$3
Token=$4
Hash=$5
K8sVersion=${6:-1.24.2}

NodeType="master"

# 设置域名本地解析
sed -i '/${MasterDomain}/d' /etc/hosts
echo "${MasterIP} ${MasterDomain}" >> /etc/hosts

# 安装conntrack
apt -y install conntrack

bash install-all.sh ${NodeType} ${K8sVersion}

kubeadm join ${MasterDomain}:6443 --token ${Token} \
--discovery-token-ca-cert-hash sha256:${Hash} \
--control-plane --certificate-key <certificate-key> \
--node-name ${NodeName}
