#!/bin/bash
set -ex

tunnelServerDomain=$1
tunnelServerPort=$2

helm repo add openyurt https://openyurtio.github.io/openyurt-helm

# 1、update coredns as daemonset
echo "-----------update coredns-----------"
kubectl annotate svc kube-dns -n kube-system openyurt.io/topologyKeys='openyurt.io/nodepool'
kubectl scale --replicas=0 deployment/coredns -n kube-system
kubectl apply -f https://raw.githubusercontent.com/huweihuang/kubeadm-scripts/main/openyurt/yurt-tunnel/coredns.ds.yaml

# 2、deploy yurt-tunnel-dns
kubectl apply -f https://raw.githubusercontent.com/huweihuang/kubeadm-scripts/main/openyurt/yurt-tunnel/yurt-tunnel-dns.yaml

# 3、update kube-proxy

# 4、install yurt-app-manager
echo "-----------install yurt-app-manager-----------"
rm -fr yurt-app-manager/
helm upgrade --install yurt-app-manager -n kube-system openyurt/yurt-app-manager

# 5、install openyurt
echo "-----------install tunnel and yurt-controller-manager-----------"
rm -fr openyurt/
helm pull openyurt/openyurt --untar

sed -i "s|certDnsNames: \"\"|certDnsNames: \"${tunnelServerDomain}\"|;
s|tunnelAgentConnectPort: \"\"|tunnelAgentConnectPort: \"${tunnelServerPort}\"|;
s|tunnelserverAddr: \"\"|tunnelserverAddr: \"${tunnelServerDomain}:${tunnelServerPort}\"|" ./openyurt/values.yaml

helm install openyurt ./openyurt
