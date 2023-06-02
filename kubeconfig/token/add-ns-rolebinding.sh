#!/bin/bash
set -e

# 给已存在的用户USER 添加其他NAMESPACE的权限
USER=$1
NAMESPACE=$2
ROLE=$3
ROLE=${ROLE:-edit}

ServiceAccountName="${USER}-user"
ServiceAccountNS="kubernetes-dashboard"

cat<<EOF | kubectl apply -f -
kind: RoleBinding
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: ${USER}-rolebinding
  namespace: ${NAMESPACE}
subjects:
- kind: ServiceAccount
  name: ${ServiceAccountName}
  namespace: ${ServiceAccountNS}
roleRef:
  kind: ClusterRole
  name: ${ROLE}
  apiGroup: rbac.authorization.k8s.io
EOF
