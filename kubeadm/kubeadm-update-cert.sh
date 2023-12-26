#!/bin/bash
set -ex

# 查看当前的证书时间
kubeadm certs check-expiration

# 备份证书文件
timestamp=$(date "+%Y%m%d%H%M%S")
cp -fr /etc/kubernetes/pki /etc/kubernetes/pki.bak.${timestamp}
cp -fr ~/.kube ~/.kube.bak.${timestamp}

# 重新生成证书
kubeadm certs renew all

# 拷贝kubeconfig
cp -fr /etc/kubernetes/admin.conf $HOME/.kube/config

# 检查是否更新
kubeadm certs check-expiration

# 先重启3台etcd，确保etcd集群可用
# crictl ps |grep "etcd"|awk '{print $1}'|xargs crictl stop 

# 再分别重启三台master的服务
# crictl ps |egrep "kube-apiserver|kube-scheduler|kube-controller"|awk '{print $1}'|xargs crictl stop 
