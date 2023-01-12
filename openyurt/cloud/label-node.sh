#!/bin/bash

nodename=$1
zone=$2
apisixNodeType=$3

kubectl label node ${nodename} topology.kubernetes.io/zone=${zone}
kubectl label node ${nodename} openyurt.io/is-edge-worker=true
kubectl label node ${nodename} apps.openyurt.io/desired-nodepool=${zone}

if [ ${apisixNodeType} -eq 1 ];then
    kubectl label node ${nodename} apisix.io/apisix-worker-zone=${zone}
fi
