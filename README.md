# kubeadm-scripts
kubeadm的部署脚本

## 安装kubeadm等组件

```bash
# clone 仓库
 git clone https://github.com/huweihuang/kubeadm-scripts.git

# 执行节点组件安装脚本
bash install-all.sh

# 或者分开执行，确认部署结果
bash kubeadm/kubeadm-init.sh
bash containerd/install-containerd.sh
bash kubeadm/install-kubeadm.sh
```

## 环境准备

```bash
# 设置域名本地解析
echo "master_ip k8s_domain" >> /etc/hosts

# 安装conntrack
apt -y install conntrack
```

## 使用kubeadm搭建集群

```bash
# 对于第一个master生成默认配置，并修改
kubeadm config print init-defaults > kubeadm-config.yaml

# 或者下载kubeadm-config.yaml并修改MasterDomain和Version
wget https://raw.githubusercontent.com/huweihuang/kubeadm-scripts/main/kubeadm/kubeadm-config.yaml
sed -i "s|_MasterDomain_|${MasterDomain}|g;
s|_K8sVersion_|${K8sVersion}|g" kubeadm-config.yaml

# kubeadm init 创建第一个master节点
kubeadm init --config kubeadm-config.yaml --upload-certs  --node-name <nodename>


# kubeadm join master 加入其他master
kubeadm join <control-plane-endpoint>:6443 --token <token> \
--discovery-token-ca-cert-hash sha256:<hash> \
--control-plane --certificate-key <certificate-key> \
--node-name <nodename>


# kubeadm join node 添加worker节点
kubeadm join <control-plane-endpoint>:6443 --token <token> \
--discovery-token-ca-cert-hash sha256:<hash> \
--node-name <nodename>
```
