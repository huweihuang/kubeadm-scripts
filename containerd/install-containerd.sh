#!/bin/bash
set -e

# reference:https://github.com/containerd/containerd/blob/main/docs/getting-started.md

ContainerdVersion=$1
ContainerdVersion=${ContainerdVersion:-1.6.8}

RuncVersion=$2
RuncVersion=${RuncVersion:-1.1.4}

CniVersion=$3
CniVersion=${CniVersion:-1.1.1}

NerdctlVersion=$4
NerdctlVersion=${NerdctlVersion:-1.1.0}

CrictlVersion=$5
CrictlVersion=${CrictlVersion:-1.26.0}

BinPath="/usr/bin"
LocalBinPath="/usr/local/bin"
ContainerRootDir="/data/containerd"

# 下载地址
ContainerdDownloadUrl="https://github.com/containerd/containerd/releases/download/v${ContainerdVersion}/containerd-${ContainerdVersion}-linux-amd64.tar.gz"
RuncDownloadUrl="https://github.com/opencontainers/runc/releases/download/v${RuncVersion}/runc.amd64"
CniDownloadUrl="https://github.com/containernetworking/plugins/releases/download/v${CniVersion}/cni-plugins-linux-amd64-v${CniVersion}.tgz"
NerdctlDownloadUrl="https://github.com/containerd/nerdctl/releases/download/v${NerdctlVersion}/nerdctl-${NerdctlVersion}-linux-amd64.tar.gz"
CrictlDownloadUrl="https://github.com/kubernetes-sigs/cri-tools/releases/download/v${CrictlVersion}/crictl-v${CrictlVersion}-linux-amd64.tar.gz"

# 下载二进制
TmpDir="/tmp/kube-bin"
mkdir -p ${TmpDir}

function download(){
    filename=$1
    file_url=$2
    install_dir=$3

    if [ ! -f "${TmpDir}/${filename}" ]; then
        echo "===========[ download ${filename} ]==========="
        wget ${file_url} -P ${TmpDir}
    fi
    mkdir -p ${install_dir}
    tar Cxzvf ${install_dir} ${TmpDir}/$filename
}

download containerd-${ContainerdVersion}-linux-amd64.tar.gz ${ContainerdDownloadUrl} /usr
download cni-plugins-linux-amd64-v${CniVersion}.tgz ${CniDownloadUrl} /opt/cni/bin
download nerdctl-${NerdctlVersion}-linux-amd64.tar.gz ${NerdctlDownloadUrl} ${LocalBinPath}
download crictl-v${CrictlVersion}-linux-amd64.tar.gz ${CrictlDownloadUrl} ${LocalBinPath}


# 安装runc
echo "===========[ install runc ]==========="
if [ ! -f "${TmpDir}/runc.${RuncVersion}" ]; then
  wget https://github.com/opencontainers/runc/releases/download/v${RuncVersion}/runc.amd64 -O ${TmpDir}/runc.${RuncVersion}
fi
cp -fr ${TmpDir}/runc.${RuncVersion} ${BinPath}/runc
chmod +x ${BinPath}/runc

cat > /etc/crictl.yaml << \EOF
runtime-endpoint: unix:///run/containerd/containerd.sock
image-endpoint: unix:///run/containerd/containerd.sock
timeout: 2
debug: false
pull-image-on-create: false
EOF


# 安装containerd
echo "===========[ install containerd ]==========="
# wget https://raw.githubusercontent.com/containerd/containerd/681aaf68b7dcbe08a51c3372cbb8f813fb4466e0/containerd.service
# mv containerd.service /lib/systemd/system/
cat > /lib/systemd/system/containerd.service << EOF
[Unit]
Description=containerd container runtime
Documentation=https://containerd.io
After=network.target local-fs.target

[Service]
ExecStartPre=-/sbin/modprobe overlay
ExecStart=/usr/bin/containerd

Type=notify
Delegate=yes
KillMode=process
Restart=always
RestartSec=5
# Having non-zero Limit*s causes performance problems due to accounting overhead
# in the kernel. We recommend using cgroups to do container-local accounting.
LimitMEMLOCK=infinity
LimitNPROC=infinity
LimitCORE=infinity
LimitNOFILE=infinity
# Comment TasksMax if your systemd version does not supports it.
# Only systemd 226 and above support this version.
TasksMax=infinity
OOMScoreAdjust=-999

[Install]
WantedBy=multi-user.target
EOF

# 修改配置
mkdir -p /etc/containerd/
containerd config default > /etc/containerd/config.toml
sed -i 's/SystemdCgroup = false/SystemdCgroup = true/' /etc/containerd/config.toml
sed -i  "s|\/var/\lib\/containerd|${ContainerRootDir}|g" /etc/containerd/config.toml

# 启动containerd服务
systemctl daemon-reload
systemctl enable --now containerd
systemctl restart containerd
