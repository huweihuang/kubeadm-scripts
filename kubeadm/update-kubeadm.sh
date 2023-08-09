#!/bin/bash

set -ex

Version=${1:-1.24.2}

# 备份kubeadm
timestamp=$(date "+%Y%m%d%l%M%S")
mv /usr/bin/kubeadm /usr/bin/kubeadm.${timestamp} 2>/dev/null || true

# 下载安装10年证书的kubeadm版本
wget https://github.com/huweihuang/kubeadm-scripts/releases/download/kubeadm/kubeadm-v${Version} -O /usr/bin/kubeadm
chmod +x /usr/bin/kubeadm

# 查看版本
kubeadm version
