# kubeadm-scripts
kubeadm的部署脚本

## 安装kubeadm等组件

```bash
# clone 仓库
git clone git@github.com:huweihuang/kubeadm-scripts.git

# 执行节点组件安装脚本
bash install-all.sh

# 或者分开执行，确认部署结果
bash kubeadm-init.sh
bash install-containerd.sh
bash install-kubeadm.sh
```

## 使用kubeadm搭建集群

```bash
# 对于第一个master生成默认配置，并修改
kubeadm config print init-defaults > kubeadm-config.yaml


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
