#!/bin/bash
set -ex

echo "##########[清理节点calico]########"

# 清理配置文件
rm -rf /etc/cni/net.d/10-calico.conflist
rm -rf /etc/cni/net.d/calico*
rm -rf /var/lib/calico

# 清理二进制
rm -rf /opt/cni/bin/calico*
rm -rf /opt/cni/bin/install

# 清理路由
ip link list | grep cali | awk '{print $2}' | cut -c 1-15 | xargs -I {} ip link delete {}

# 清理iptables规则
iptables-save > /tmp/iptables-before-clean-calico.txt
iptables-save | egrep -v "cali" | iptables-restore

#  删除ipip模块
modprobe -r ipip

# 清理bird协议的路由
ip route flush proto bird

echo "##########[检查清理结果]########"

# 查看是否有cali或tunl0网卡
ip a | egrep "cali|tunl0"

# 查看是否有bird协议的路由
ip route list proto bird 

# 查看是否有cali相关iptables规则
iptables-save | grep cali
