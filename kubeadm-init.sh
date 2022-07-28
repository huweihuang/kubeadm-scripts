#!/bin/bash
set -e

### init node ###

# master节点开放端口
#iptables -A INPUT -p tcp -m multiport --dports 6443,2379,2380,10250 -j ACCEPT
iptables -A INPUT -p tcp --dport 10250 -j ACCEPT

swapoff -a

# 设置加载br_netfilter模块
cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF

sudo modprobe overlay
sudo modprobe br_netfilter

# 开启bridge-nf-call-iptables ，设置所需的 sysctl 参数，参数在重新启动后保持不变
cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
EOF

# 应用 sysctl 参数而不重新启动
sudo sysctl --system