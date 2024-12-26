#!/bin/bash
set -e

NodeType=
MasterDomain=
MasterIP=
NodeName=
Token=
Hash=
CertificateKey=
SetupTenYearCert=

# 版本
K8sVersion=$(grep K8sVersion version | awk -F "=" '{print $2}')
ContainerdVersion=$(grep ContainerdVersion version | awk -F "=" '{print $2}')
RuncVersion=$(grep RuncVersion version | awk -F "=" '{print $2}')
CniVersion=$(grep CniVersion version | awk -F "=" '{print $2}')
NerdctlVersion=$(grep NerdctlVersion version | awk -F "=" '{print $2}')
CrictlVersion=$(grep CrictlVersion version | awk -F "=" '{print $2}')

LogDir="/tmp/kube-bin"

function usage() {
    shellname="$(echo ${0##*/})"

    echo -e "usage:
	-h                         显示帮助
	-t [NodeType]              节点类型：(master, node)
	-d [MasterDomain]          apiserver域名
	-m [MasterIP]              Master IP/VIP
	-n [NodeName]              节点名称
	-k [Token]                 添加master/node的Token
	-a [Hash]                  添加master/node的Hash
	-c [CertificateKey]        添加master的CertificateKey
	-u true                    可选参数，更新为10年证书的kubeadm
"

    echo "example:

# init first master
bash setup-k8s.sh -t master -d [MasterDomain] -m [MasterIP] -n [NodeName] 

# join the other master
bash setup-k8s.sh -t master -d [MasterDomain] -m [MasterIP] -n [NodeName] -k [Token] -a [Hash] -c [CertificateKey]

# join node
bash setup-k8s.sh -t node -d [MasterDomain] -m [MasterIP] -n [NodeName] -k [Token] -a [Hash]
"
    exit
}

while getopts "ht:d:m:n:i:k:a:c:u:" opt; do
    case $opt in
    t)
        NodeType=$OPTARG
        echo "NodeType VALUE: $OPTARG"
        ;;
    d)
        MasterDomain=$OPTARG
        echo "MasterDomain VALUE: $OPTARG"
        ;;
    m)
        MasterIP=$OPTARG
        echo "MasterIP VALUE: $OPTARG"
        ;;
    n)
        NodeName=$OPTARG
        echo "NodeName VALUE: $OPTARG"
        ;;
    k)
        Token=$OPTARG
        echo "Token VALUE: $OPTARG"
        ;;
    a)
        Hash=$OPTARG
        echo "Hash VALUE: $OPTARG"
        ;;
    c)
        CertificateKey=$OPTARG
        echo "CertificateKey VALUE: $OPTARG"
        ;;
    u)
        SetupTenYearCert=$OPTARG
        echo "SetupTenYearCert VALUE: $OPTARG"
        ;;
    h) usage ;;
    ?) usage ;;
    esac
done

function version_ge() {
    test "$(echo "$@" | tr " " "\n" | sort -rV | head -n 1)" == "$1"
}

function init_node() {
    echo "[=======install kubelet and containerd=======]"
    # 设置域名本地解析
    sed -i "/${MasterDomain}/d" /etc/hosts
    echo "${MasterIP} ${MasterDomain}" >>/etc/hosts

    # 安装conntrack
    apt -y install conntrack

    # 安装containerd kubelet组件
    bash install-all.sh ${NodeType} ${K8sVersion} ${ContainerdVersion} ${RuncVersion} ${CniVersion} ${NerdctlVersion} ${CrictlVersion}
}

function copy_kubeconfig() {
    mkdir -p $HOME/.kube
    sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
    sudo chown $(id -u):$(id -g) $HOME/.kube/config
}

function init_master() {
    timestamp=$(date "+%Y-%m-%d %H:%M:%S")
    echo "[================[${timestamp}] init master================]"

    # 如果版本大于1.31.0则使用v1beta4的配置
    kubeadmConfigVersion="v1beta3"
    if version_ge ${K8sVersion} "1.31.0"; then
        kubeadmConfigVersion="v1beta4"
    fi

    # 下载kubeadm-config.yaml并修改MasterDomain和Version
    wget https://raw.githubusercontent.com/huweihuang/kubeadm-scripts/main/kubeadm/config/kubeadm-config-${kubeadmConfigVersion}.yaml -O kubeadm-config.yaml
    sed -i "s|_MasterDomain_|${MasterDomain}|g;
    s|_K8sVersion_|${K8sVersion}|g" kubeadm-config.yaml

    # 1.31.0版本后可直接在kubeadm的config中配置证书的时间，此处修改为10年
    if [ ${SetupTenYearCert} ] && [ version_ge ${K8sVersion} "1.31.0" ]; then
        sed -i 's/certificateValidityPeriod: 8760h0m0s/certificateValidityPeriod: 87600h0m0s/g' kubeadm-config.yaml
    fi

    # 如果版本大于1.28.0则修改镜像仓库地址，如果版本大于1.31.0则无需修改（即此修改不生效）
    if version_ge ${K8sVersion} "1.28.0"; then
        sed -i 's/k8s.gcr.io/registry.k8s.io/g' kubeadm-config.yaml
    fi

    # kubeadm init 创建第一个master节点
    kubeadm init --config kubeadm-config.yaml --upload-certs --node-name ${NodeName}
    copy_kubeconfig
}

# 添加节点
function join_node() {
    timestamp=$(date "+%Y-%m-%d %H:%M:%S")
    echo "[================[${timestamp}] join node================]"
    kubeadm join ${MasterDomain}:6443 --token ${Token} \
        --discovery-token-ca-cert-hash sha256:${Hash} \
        --node-name ${NodeName}
}

# 添加master
function join_master() {
    timestamp=$(date "+%Y-%m-%d %H:%M:%S")
    echo "[================[${timestamp}] join master================]"
    kubeadm join ${MasterDomain}:6443 --token ${Token} \
        --discovery-token-ca-cert-hash sha256:${Hash} \
        --control-plane --certificate-key ${CertificateKey} \
        --node-name ${NodeName}
    copy_kubeconfig
}

# 重置节点
function reset_node(){
    echo "[=======reset node and clean data=======]"
    bash kubeadm/kubeadm-reset.sh >> ${LogDir}/kubeadm.log
}

main() {
    init_node
    reset_node

    mkdir -p ${LogDir}

    # k8s版本小于1.31.0则通过升级kubeadm为10年证书的版本（修改代码重新编译kubeadm）
    if [ ${SetupTenYearCert} ] && [ version_ge "1.31.0" ${K8sVersion} ]; then
        bash kubeadm/upgrade/update-kubeadm.sh ${K8sVersion}
    fi

    case ${NodeType} in
    "master")
        # 如果以下参数都为空，则init master
        if [ -z ${Token} ] && [ -z ${Hash} ] && [ -z ${CertificateKey} ]; then
            init_master > ${LogDir}/kubeadm.log
            cat ${LogDir}/kubeadm.log
        # 如果以下参数都不为空，则join master
        elif [ ${Token} ] && [ ${Hash} ] && [ ${CertificateKey} ]; then
            join_master > ${LogDir}/kubeadm.log
            cat ${LogDir}/kubeadm.log
        else
            echo "invalid Token,Hash,CertificateKey"
        fi
        ;;
    "node")
        join_node > ${LogDir}/kubeadm.log
        cat ${LogDir}/kubeadm.log
        ;;
    *)
        echo "invalid NodeType"
        ;;
    esac
}

main
