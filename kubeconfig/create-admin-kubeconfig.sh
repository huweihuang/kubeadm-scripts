#!/bin/bash
# set -e
set -x

APISERVER=$1

KubeDir="${HOME}/.kube"
USER="admin-user"

# 创建配置文件
cat > kubeadm-config.yaml <<EOF
apiVersion: kubeadm.k8s.io/v1beta3
kind: ClusterConfiguration
# kubernetes 将作为 kubeconfig 中集群名称
clusterName: "kubernetes"
# some-dns-address:6443 将作为集群 kubeconfig 文件中服务地址（IP 或者 DNS 名称）
controlPlaneEndpoint: "${APISERVER}:6443"
# 从本地挂载集群的 CA 秘钥和 CA 证书
certificatesDir: "/etc/kubernetes/pki"
EOF

# 创建用户,用户名：${USER}
mkdir -p ${KubeDir}
kubeadm kubeconfig user --client-name=${USER} --config=kubeadm-config.yaml > ${KubeDir}/${USER}.yaml

# 配置权限，创建sa和ClusterRoleBinding
cat > dashboard-adminuser.yaml <<EOF
apiVersion: v1
kind: ServiceAccount
metadata:
  name: admin-user
  namespace: kubernetes-dashboard
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: admin-user
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin
subjects:
- kind: ServiceAccount
  name: admin-user
  namespace: kubernetes-dashboard
EOF

kubectl apply -f dashboard-adminuser.yaml

# 设置kubeconfig中namespace的token(过期时间365天)，用于登录dashboard
TOKEN=$(kubectl -n kubernetes-dashboard create token ${USER} --duration 8760h)
kubectl --kubeconfig=${KubeDir}/${USER}.yaml config set-credentials ${USER} --token=${TOKEN}
