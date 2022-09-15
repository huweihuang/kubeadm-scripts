#!/bin/bash
set -e
set -x

### install yurthub ###
mkdir -p /etc/kubernetes/manifests/
cd /etc/kubernetes/manifests/
wget https://raw.githubusercontent.com/openyurtio/openyurt/master/config/setup/yurthub.yaml 


### 修改master和token字段
sed -i 's|__kubernetes_master_address__|__k8s_addr__|;
s|__bootstrap_token__|__token__|' /etc/kubernetes/manifests/yurthub.yaml

mkdir -p /var/lib/openyurt
cat << EOF > /var/lib/openyurt/kubelet.conf
apiVersion: v1
clusters:
- cluster:
    server: http://127.0.0.1:10261
  name: default-cluster
contexts:
- context:
    cluster: default-cluster
    namespace: default
    user: default-auth
  name: default-context
current-context: default-context
kind: Config
preferences: {}
EOF

cp /etc/systemd/system/kubelet.service.d/10-kubeadm.conf /etc/systemd/system/kubelet.service.d/10-kubeadm.conf.bak
sed -i "s|KUBELET_KUBECONFIG_ARGS=--bootstrap-kubeconfig=\/etc\/kubernetes\/bootstrap-kubelet.conf\ --kubeconfig=\/etc\/kubernetes\/kubelet.conf|KUBELET_KUBECONFIG_ARGS=--kubeconfig=\/var\/lib\/openyurt\/kubelet.conf|g" \
    /etc/systemd/system/kubelet.service.d/10-kubeadm.conf

systemctl daemon-reload && systemctl restart kubelet
