#!/bin/bash
set -e

USER=$1
USER_NAMESPACE=$2
APISERVER=$3

ServiceAccountNS="kubernetes-dashboard"
KubeDir="${HOME}/.kube"

ServiceAccountName="${USER}-user"
SecretName="${ServiceAccountName}-secret"
RoleName="${ServiceAccountName}-role"
RoleBindingName="${ServiceAccountName}-rolebinding"
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
cat<<EOF | kubectl apply -f -
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  namespace: ${USER_NAMESPACE}
  name: ${RoleName}
rules:
- apiGroups: ["*"] 
  resources: ["pods"]
  verbs: ["*"]
EOF

# 4. 绑定权限
cat<<EOF | kubectl apply -f -
kind: RoleBinding
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: ${RoleBindingName}
  namespace: ${USER_NAMESPACE}
subjects:
- kind: ServiceAccount
  name: ${ServiceAccountName}
  namespace: ${ServiceAccountNS}
roleRef:
  kind: Role
  name: ${RoleName}
  apiGroup: rbac.authorization.k8s.io
EOF

# 5. 基于secret获取token
TOKEN=$(kubectl get secret ${SecretName} -n ${ServiceAccountNS} -o jsonpath={".data.token"} | base64 -d)

# 6. 创建kubeconfig文件
kubectl --kubeconfig=${KubeDir}/${USER}.yaml config set-cluster ${KubeConfigCluster} \
  --server=https://${APISERVER} \
  --certificate-authority=${CaFilePath} \
  --embed-certs=true
kubectl --kubeconfig=${KubeDir}/${USER}.yaml config set-credentials ${USER} --token=${TOKEN}
kubectl --kubeconfig=${KubeDir}/${USER}.yaml config set-context ${USER}@${KubeConfigCluster} \
  --cluster=${KubeConfigCluster} --user=${USER} --namespace=${USER_NAMESPACE}
kubectl --kubeconfig=${KubeDir}/${USER}.yaml config use-context ${USER}@${KubeConfigCluster}
kubectl --kubeconfig=${KubeDir}/${USER}.yaml config view
