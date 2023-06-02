#!/bin/bash
set -e

USER=$1
USER_NAMESPACE=$2
ROLE=$3
ROLE=${ROLE:-edit}

ServiceAccountName="${USER}-user"
ServiceAccountNS="kubernetes-dashboard"
SecretName="${ServiceAccountName}-secret"
TOKEN_DIR="${HOME}/.kube/token"

# 1. 创建权限: 可以自定义权限，或者使用clusterrole: admin/edit/view权限

# 2. 创建用户
cat<<EOF | kubectl apply -f -
apiVersion: v1
kind: ServiceAccount
metadata:
  namespace: ${ServiceAccountNS}
  name: ${ServiceAccountName}
EOF

# 3. 绑定权限
cat<<EOF | kubectl apply -f -
kind: RoleBinding
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: ${USER}-rolebinding
  namespace: ${USER_NAMESPACE}
subjects:
- kind: ServiceAccount
  name: ${ServiceAccountName}
  namespace: ${ServiceAccountNS}
roleRef:
  kind: ClusterRole
  name: ${ROLE}
  apiGroup: rbac.authorization.k8s.io
EOF

# 4. 创建Secret绑定ServiceAccount
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

# 5. 基于secret获取token
TOKEN=$(kubectl get secret ${SecretName} -n ${ServiceAccountNS} -o jsonpath={".data.token"} | base64 -d)
mkdir -p ${TOKEN_DIR}
echo ${TOKEN} > ${TOKEN_DIR}/${USER}.token
echo "---------[Token]---------"
echo ${TOKEN}
