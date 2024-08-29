# 使用kubeadm搭建集群

详细步骤可以参考：[使用kubeadm部署生产环境kubernetes集群 ](https://blog.huweihuang.com/kubernetes-notes/setup/installer/install-k8s-by-kubeadm/)

```bash
git clone https://github.com/huweihuang/kubeadm-scripts.git
```

命令说明：

```bash
$ bash setup-k8s.sh -h
usage:
        -h                         显示帮助
        -t [NodeType]              节点类型：(master, node)
        -d [MasterDomain]          apiserver域名
        -m [MasterIP]              Master IP/VIP
        -n [NodeName]              节点名称
        -k [Token]                 添加master/node的Token
        -a [Hash]                  添加master/node的Hash
        -c [CertificateKey]        添加master的CertificateKey
        -u true                    可选参数，更新为10年证书的kubeadm

example:

# init first master
bash setup-k8s.sh -t master -d [MasterDomain] -m [MasterIP] -n [NodeName] 

# join the other master
bash setup-k8s.sh -t master -d [MasterDomain] -m [MasterIP] -n [NodeName] -k [Token] -a [Hash] -c [CertificateKey]

# join node
bash setup-k8s.sh -t node -d [MasterDomain] -m [MasterIP] -n [NodeName] -k [Token] -a [Hash]
```

## 0. 设置组件版本

修改`version`文件中的组件版本号。

```bash
K8sVersion=1.28.0
ContainerdVersion=1.7.5
RuncVersion=1.1.9
CniVersion=1.3.0
NerdctlVersion=1.5.0
CrictlVersion=1.28.0
```
## 1. 创建Master

```bash
bash setup-k8s.sh -t master -d [MasterDomain] -m [MasterIP] -n [NodeName] 
```

## 2. 生成Token

```bash
kubeadm token create --print-join-command
# 输出
kubeadm join xxx:6443 --token <token> --discovery-token-ca-cert-hash sha256:<hash>
```

## 3. 添加Master

```bash
bash setup-k8s.sh -t master -d [MasterDomain] -m [MasterIP] -n [NodeName] -k [Token] -a [Hash] -c [CertificateKey]
```

## 4. 添加Node

```bash
bash setup-k8s.sh -t node -d [MasterDomain] -m [MasterIP] -n [NodeName] -k [Token] -a [Hash]
```

## 5. 安装CNI组件

任选一种网络插件安装。

- 安装flannel网络插件

```bash
cd cni/
bash install-flannel.sh
```

- 安装calico网络插件

```bash
cd cni/
bash install-calico.sh
```

## 6. 安装dashboard,metrics-server

```bash
cd master/
bash install-dashboard.sh
bash install-metrics-server.sh
```
