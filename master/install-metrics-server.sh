#!/bin/bash
set -ex

wget https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml

# 添加kubelet-insecure-tls参数
sed -i '/metric-resolution/a\
        - --kubelet-insecure-tls' components.yaml

kubectl apply -f components.yaml
