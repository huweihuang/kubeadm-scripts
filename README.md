# 使用kubeadm搭建集群

详细步骤可以参考：[使用kubeadm部署生产环境kubernetes集群 ](https://blog.huweihuang.com/kubernetes-notes/setup/installer/install-k8s-by-kubeadm/)

```bash
git clone https://github.com/huweihuang/kubeadm-scripts.git
```

## 1. 创建Master

```bash
bash install-master.sh <MasterDomain> <MasterIP> 
```

## 2. 生成Token

```bash
kubeadm token create --print-join-command
# 输出
kubeadm join xxx:6443 --token <token> --discovery-token-ca-cert-hash sha256:<hash>
```

## 3. 添加Master

```bash
bash join-master.sh <MasterDomain> <MasterIP> <NodeName> <Token> <Hash>
```

## 4. 添加Node

```bash
bash install-node.sh <MasterDomain> <MasterIP> <NodeName> <Token> <Hash>
```

## 5. 安装CNI组件

```bash
cd cni/
bash install-flannel.sh
```

## 6. 安装dashboard,metrics-server

```bash
cd master/
bash install-dashboard.sh
bash install-metrics-server.sh
```
