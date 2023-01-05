#!/bin/bash
set -e

# 设置节点类型
NodeType=$1
NodeType=${NodeType:-node}

# 设置默认组件版本
K8sVersion=$2
K8sVersion=${K8sVersion:-1.24.2}

ContainerdVersion=$3
ContainerdVersion=${ContainerdVersion:-1.6.8}

RuncVersion=$4
RuncVersion=${RuncVersion:-1.1.4}

# 下载节点套件
bash kubeadm/kubeadm-init.sh ${NodeType}
bash containerd/install-containerd.sh ${ContainerdVersion} ${RuncVersion}
bash kubeadm/install-kubeadm.sh ${K8sVersion}
