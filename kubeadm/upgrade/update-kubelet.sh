#!/bin/bash
set -ex
### upgrade kubelet kubectl ###

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

download kubelet ${Version}
download kubectl ${Version}


function upgrade(){
    install_path=$1
    file_path=$2

    # 备份
    timestamp=$(date "+%Y%m%d%l%M%S")
    mv ${install_path} ${install_path}.${timestamp} 2>/dev/null || true

    # 拷贝文件
    cp ${file_path} ${install_path}
    chmod +x ${install_path}
}

# 升级二进制
systemctl stop kubelet
BinPath="/usr/bin"
upgrade ${BinPath}/kubelet ${TmpDir}/kubelet
upgrade ${BinPath}/kubectl ${TmpDir}/kubectl


# 重启kubelet服务
systemctl daemon-reload
systemctl enable kubelet
systemctl restart kubelet
