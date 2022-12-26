#!/bin/bash
set -ex

tunnelServerDomain=$1
tunnelServerPort=$2

helm repo add openyurt https://openyurtio.github.io/openyurt-helm

# yurt-app-manager
echo "-----------install yurt-app-manager-----------"
rm -fr yurt-app-manager/
helm upgrade --install yurt-app-manager -n kube-system openyurt/yurt-app-manager

# install openyurt
echo "-----------install tunnel and yurt-controller-manager-----------"
rm -fr openyurt/
helm pull openyurt/openyurt --untar

sed -i "s|certDnsNames: \"\"|certDnsNames: \"${tunnelServerDomain}\"|;
s|tunnelAgentConnectPort: \"\"|tunnelAgentConnectPort: \"${tunnelServerPort}\"|;
s|tunnelserverAddr: \"\"|tunnelserverAddr: \"${tunnelServerDomain}:${tunnelServerPort}\"|" ./openyurt/values.yaml

helm install openyurt ./openyurt
