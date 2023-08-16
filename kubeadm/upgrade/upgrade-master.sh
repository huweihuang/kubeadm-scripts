#!/bin/bash
set -ex

version=${1:-1.24.2}
masterType=${2}

# 下载kubeadm
bash update-kubeadm.sh ${version}

# 升级master节点，第一个master节点与其他master节点命令不同
if [ ${masterType} == "first" ]; then
    kubeadm upgrade apply ${version}
fi
kubeadm upgrade node

# 升级kubelet
bash update-kubelet.sh ${version}
