#!/bin/bash

set -ex

DashboardVersion=$1
DashboardVersion=${DashboardVersion:-v2.7.0}

kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/${DashboardVersion}/aio/deploy/recommended.yaml
