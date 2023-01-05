#!/bin/bash
set -ex

# get token and hash on master node
# kubeadm token create --print-join-command

MasterDomain=$1
MasterIP=$2
NodeName=$3
Token=$4
Hash=$5
K8sVersion=$6
K8sVersion=${K8sVersion:-1.24.2}
NodeType="node"

# 设置域名本地解析
sed -i '/${MasterDomain}/d' /etc/hosts
echo "${MasterIP} ${MasterDomain}" >> /etc/hosts

# install conntrack
apt -y install conntrack

bash install-all.sh ${NodeType} ${K8sVersion}

kubeadm join ${MasterDomain}:6443 --token ${Token} \
--discovery-token-ca-cert-hash sha256:${Hash} \
--node-name ${NodeName}
