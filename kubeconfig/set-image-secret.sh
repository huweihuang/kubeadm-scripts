#!/bin/bash
set -x

NAMESPACE=$1
DOCKER_REGISTRY_SERVER=$2
DOCKER_USER=$3
DOCKER_PASSWORD=$4

kubectl create secret docker-registry ${DOCKER_REGISTRY_SERVER} --docker-server=${DOCKER_REGISTRY_SERVER} --docker-username=${DOCKER_USER} --docker-password=${DOCKER_PASSWORD} -n ${NAMESPACE}
kubectl patch serviceaccount default -p '{"imagePullSecrets":[{"name":"'${DOCKER_REGISTRY_SERVER}'"}]}' -n ${NAMESPACE} 
