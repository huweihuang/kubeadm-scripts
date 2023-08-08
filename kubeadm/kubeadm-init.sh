#!/bin/bash
set -ex

### init node ###
NodeType=$1
NodeType=${NodeType:-node}
iptablesRule=

# 设置iptables规则
if [ ${NodeType} == "master" ]; then
    # master节点开放端口
    iptablesRule="-A INPUT -p tcp -m multiport --dports 6443,2379,2380,10250 -j ACCEPT -m comment --comment k8s-port"
else
    # node节点开放端口
    iptablesRule="-A INPUT -p tcp --dport 10250 -j ACCEPT -m comment --comment k8s-port"
fi
iptables ${iptablesRule}

# 开通flannel vxlan udp端口8472
iptables -A INPUT -p udp --dport 8472 -j ACCEPT -m comment --comment "flannel-port"

# 持久化iptables规则
cat >> /etc/sysconfig/iptables <<EOF
${iptablesRule}
-A INPUT -p udp --dport 8472 -j ACCEPT -m comment --comment "flannel-port"
EOF


swapoff -a
swap_result=$(free -m |grep Swap | awk '{print $2}')
if [ "$swap_result" -ne 0 ]; then
    echo "Swap set off failed. Please check it"
    exit 1
else
    echo "Swap set off succeed."
fi

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