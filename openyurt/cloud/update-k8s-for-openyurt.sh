#!/bin/bash
set -ex

YAML_DIR="/etc/kubernetes/manifests"

# update kube-controller-manager
sed -i "s|- --controllers=\*,bootstrapsigner,tokencleaner|- --controllers=\*,bootstrapsigner,tokencleaner,-nodelifecycle|g" ${YAML_DIR}/kube-controller-manager.yaml

# update kube-apiserver
sed -i "s|- --kubelet-preferred-address-types=InternalIP,ExternalIP,Hostname|- --kubelet-preferred-address-types=Hostname,InternalIP,ExternalIP|g" ${YAML_DIR}/kube-apiserver.yaml

# update dns policy
sed -i '/dnsPolicy: "ClusterFirst"/c\
  dnsPolicy: "None"\
  dnsConfig:\
    nameservers:\
      - 10.99.53.96\
    searches:\
      - kube-system.svc.cluster.local\
      - svc.cluster.local\
      - cluster.local\
    options:\
      - name: ndots\
        value: "5"' ${YAML_DIR}/kube-apiserver.yaml

