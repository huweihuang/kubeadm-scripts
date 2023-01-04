## install openyurt control plane

```bash
# 登录三个master节点，调整k8s配置
bash update-k8s-for-openyurt.sh

# 安装openyurt云端组件
bash helm-install-openyurt.sh {tunnelServerDomain} {tunnelServerPort}
```

## install yurthub

```bash
# create token
kubeadm token create

# exec script
bash install-yurthub.sh {custom_k8s_addr} {custom_token}
```
