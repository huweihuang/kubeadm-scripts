#!/bin/bash
set -e
set -x

APISERVER=$1
USER=$2
ROLE=$3
ROLE=${ROLE:-edit}

KubeDir="${HOME}/.kube"

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

# 创建用户
mkdir -p ${KubeDir}
kubeadm kubeconfig user --client-name=${USER} --config=kubeadm-config.yaml > ${KubeDir}/${USER}.yaml

# 创建 namespace
kubectl get ns ${USER}
if [ $? -ne 0 ];then
    kubectl create ns ${USER}
fi

# 绑定用户的namespace的admin/edit/view权限
kubectl get rolebinding ${USER}-admin-binding --namespace=${USER}
if [ $? -ne 0 ];then
    kubectl create rolebinding ${USER}-admin-binding --clusterrole=${ROLE} --user=${USER} --namespace=${USER} --serviceaccount=${USER}:default
fi

# 设置kubeconfig的默认namespace
export KUBECONFIG=${KubeDir}/${USER}.yaml
kubectl --kubeconfig=${KubeDir}/${USER}.yaml config set-context --current --namespace=${USER}
