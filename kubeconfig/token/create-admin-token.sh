#!/bin/bash
set -e

USER="admin-user"
NAMESPACE="kubernetes-dashboard"
ROLE="cluster-admin"
TOKEN_DIR="${HOME}/.kube/token"

# 配置权限，创建sa和ClusterRoleBinding
cat > dashboard-adminuser.yaml <<EOF
apiVersion: v1
kind: ServiceAccount
metadata:
  name: ${USER}
  namespace: ${NAMESPACE}

---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: ${USER}
subjects:
- kind: ServiceAccount
  name: ${USER}
  namespace: ${NAMESPACE}
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: ${ROLE}

---
apiVersion: v1
kind: Secret
metadata:
  name: ${USER}-secret
  namespace: ${NAMESPACE}
  annotations:
    kubernetes.io/service-account.name: "${USER}"   
type: kubernetes.io/service-account-token  
EOF

kubectl apply -f dashboard-adminuser.yaml

# 5. 基于secret获取token
TOKEN=$(kubectl get secret ${USER}-secret -n ${NAMESPACE} -o jsonpath={".data.token"} | base64 -d)
mkdir -p ${TOKEN_DIR}
echo ${TOKEN} > ${TOKEN_DIR}/${USER}.token
echo "---------[Token]---------"
echo ${TOKEN}
