#!/bin/bash
set -ex

ZONE=$1

cat <<EOF | kubectl apply -f -
apiVersion: apps.openyurt.io/v1beta1
kind: NodePool
metadata:
  name: $ZONE
spec:
  type: Edge
  annotations:
    topology.kubernetes.io/zone: $ZONE
  labels:
    topology.kubernetes.io/zone: $ZONE
EOF
