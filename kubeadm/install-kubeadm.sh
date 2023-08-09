#!/bin/bash
set -ex
### install kubeadm kubelet kubectl ###

Version=${1:-1.24.2}


# 下载二进制
TmpDir="/tmp/kube-bin/${Version}"
mkdir -p ${TmpDir}

function download(){
    filename=$1
    file_version=$2

    if [ ! -f "${TmpDir}/${filename}" ]; then
        echo "===========[ download ${filename} ]==========="
        wget https://dl.k8s.io/release/v${file_version}/bin/linux/amd64/${filename} -P ${TmpDir}
    fi
}

download kubeadm ${Version}
download kubelet ${Version}
download kubectl ${Version}


# 拷贝二进制
BinPath="/usr/bin"
rm -f ${BinPath}/kubeadm ${BinPath}/kubelet ${BinPath}/kubectl
cp ${TmpDir}/kubeadm ${TmpDir}/kubelet ${TmpDir}/kubectl ${BinPath}
chmod +x ${BinPath}/kubeadm ${BinPath}/kubelet ${BinPath}/kubectl


echo "===========[ install kubelet ]==========="
# add kubelet serivce
cat > /lib/systemd/system/kubelet.service << EOF
[Unit]
Description=kubelet: The Kubernetes Node Agent
Documentation=https://kubernetes.io/docs/home/
Wants=network-online.target
After=network-online.target

[Service]
ExecStart=/usr/bin/kubelet
Restart=always
StartLimitInterval=0
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF

mkdir -p /etc/systemd/system/kubelet.service.d
cat > /etc/systemd/system/kubelet.service.d/10-kubeadm.conf << \EOF
# Note: This dropin only works with kubeadm and kubelet v1.11+
[Service]
Environment="KUBELET_KUBECONFIG_ARGS=--bootstrap-kubeconfig=/etc/kubernetes/bootstrap-kubelet.conf --kubeconfig=/etc/kubernetes/kubelet.conf"
Environment="KUBELET_CONFIG_ARGS=--config=/var/lib/kubelet/config.yaml"
# This is a file that "kubeadm init" and "kubeadm join" generates at runtime, populating the KUBELET_KUBEADM_ARGS variable dynamically
EnvironmentFile=-/var/lib/kubelet/kubeadm-flags.env
# This is a file that the user can use for overrides of the kubelet args as a last resort. Preferably, the user should use
# the .NodeRegistration.KubeletExtraArgs object in the configuration files instead. KUBELET_EXTRA_ARGS should be sourced from this file.
EnvironmentFile=-/etc/default/kubelet
ExecStart=
ExecStart=/usr/bin/kubelet $KUBELET_KUBECONFIG_ARGS $KUBELET_CONFIG_ARGS $KUBELET_KUBEADM_ARGS $KUBELET_EXTRA_ARGS
EOF

# 启动kubelet服务
systemctl daemon-reload
systemctl enable kubelet
systemctl restart kubelet
