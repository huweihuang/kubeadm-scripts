#!/bin/bash
set -e

USER=$1
APISERVER=$2

ServiceAccountNS="kubernetes-dashboard"
KubeDir="${HOME}/.kube"

ServiceAccountName="${USER}-user"
SecretName="${ServiceAccountName}-secret"
ClusterRoleName="${ServiceAccountName}-clusterrole"
ClusterRoleBindingName="${ServiceAccountName}-clusterrolebinding"
KubeConfigCluster="kubernetes"
CaFilePath="/etc/kubernetes/pki/ca.crt"


# 1. 创建用户
cat<<EOF | kubectl apply -f -
apiVersion: v1
kind: ServiceAccount
metadata:
  namespace: ${ServiceAccountNS}
  name: ${ServiceAccountName}
EOF

# 2. 创建Secret绑定ServiceAccount
# k8s 1.24后的版本不再自动生成secret，绑定后当删除ServiceAccount时会自动删除secret
cat<<EOF | kubectl apply -f -
apiVersion: v1
kind: Secret
metadata:
  name: ${SecretName}
  namespace: ${ServiceAccountNS}
  annotations:
    kubernetes.io/service-account.name: "${ServiceAccountName}"   
type: kubernetes.io/service-account-token
EOF

# 3. 创建权限: 可以自定义权限，或者使用clusterrole: admin/edit/view权限
# 只读权限：verbs: ["get","list","watch"]
# 可写权限：verbs: ["create","update","patch"，"delete","deletecollection"]
# 全部权限：verbs: ["*"]
cat<<EOF | kubectl apply -f -
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: ${ClusterRoleName}
rules:
- apiGroups:
  - '*'
  resources:
  - pods
  - pods/log
  - pods/status
  - pods/attach
  - pods/exec
  - pods/portforward
  - pods/proxy
  - deployments
  - deployments/scale
  - deployments/status
  - replicasets
  - replicasets/scale
  - replicasets/status
  - services
  - secrets  
  verbs:
  - '*'
EOF

# 4. 绑定权限
cat<<EOF | kubectl apply -f -
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: ${ClusterRoleBindingName}
subjects:
- kind: ServiceAccount
  name: ${ServiceAccountName}
  namespace: ${ServiceAccountNS}
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: ${ClusterRoleName}
EOF

# 5. 基于secret获取token
TOKEN=$(kubectl get secret ${SecretName} -n ${ServiceAccountNS} -o jsonpath={".data.token"} | base64 -d)

# 6. 创建kubeconfig文件
kubectl --kubeconfig=${KubeDir}/${USER}.yaml config set-cluster ${KubeConfigCluster} \
  --server=https://${APISERVER} \
  --certificate-authority=${CaFilePath} \
  --embed-certs=true
kubectl --kubeconfig=${KubeDir}/${USER}.yaml config set-credentials ${USER} --token=${TOKEN}
kubectl --kubeconfig=${KubeDir}/${USER}.yaml config set-context ${USER}@${KubeConfigCluster} --cluster=${KubeConfigCluster} --user=${USER}
kubectl --kubeconfig=${KubeDir}/${USER}.yaml config use-context ${USER}@${KubeConfigCluster}
kubectl --kubeconfig=${KubeDir}/${USER}.yaml config view
