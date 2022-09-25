#!/bin/bash
set -e

bash kubeadm/kubeadm-init.sh
bash containerd/install-containerd.sh
bash kubeadm/install-kubeadm.sh
