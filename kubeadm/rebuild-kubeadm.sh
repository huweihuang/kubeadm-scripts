#!/bin/bash
set -x
# 本脚本用于重新编译kubeadm以支持设置指定时间的证书文件（设置10年证书）

K8sVersion=${1:-1.27.4}
CertExpirationTime=${2:-10}  # 默认重新编译的证书过期时间为10年

# 下载源码
if [ ! -f "v${K8sVersion}.tar.gz" ]; then
  wget https://github.com/kubernetes/kubernetes/archive/refs/tags/v${K8sVersion}.tar.gz
fi

tar -zxf v${K8sVersion}.tar.gz
cd kubernetes-${K8sVersion}/

# 修改证书过期时间
sed_command="s/CertificateValidity = time.Hour \* 24 \* 365/CertificateValidity = time.Hour * 24 * 365 * ${CertExpirationTime}/g"
sed -i "${sed_command}" ./cmd/kubeadm/app/constants/constants.go
echo "--------------[Modified CertificateValidity]-------------"
grep "CertificateValidity" ./cmd/kubeadm/app/constants/constants.go

# 重新编译
# 通过kube-build镜像编译(依赖docker服务)，保持与k8s官方构建环境一致，由于镜像过大(>5G)首次构建下载镜像的时间比较久。
build/run.sh make kubeadm

# 查看二进制版本
cp -fr _output/dockerized/bin/linux/amd64/kubeadm ../kubeadm-v${K8sVersion}
cd ../ 
./kubeadm-v${K8sVersion} version
sha256sum kubeadm-v${K8sVersion} > kubeadm-v${K8sVersion}.sha256sum
