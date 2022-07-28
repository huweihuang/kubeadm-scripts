#!/bin/bash
set -e

bash kubeadm-init.sh
bash install-containerd.sh
bash install-kubeadm.sh