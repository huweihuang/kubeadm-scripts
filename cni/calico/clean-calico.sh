#!/bin/bash
set -ex

wget https://raw.githubusercontent.com/projectcalico/calico/master/manifests/calico.yaml
sed -i 's/kube-system/calico-system/g' calico.yaml
kubectl delete -f calico.yaml
kubectl delete ns calico-system
rm -fr calico.yaml
