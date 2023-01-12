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

## create nodepool

```bash
bash apply-nodepool.sh <zone>
```

add node lable

```bash
bash label-node.sh <nodename> <zone>
```

### 配置kube-proxy

- 开启 kube-proxy 的 EndpointSliceProxying [特性门控]
- 配置其连接 Yurthub。

```
$ kubectl edit cm -n kube-system kube-proxy
apiVersion: v1
data:
  config.conf: |-
    apiVersion: kubeproxy.config.k8s.io/v1alpha1
    bindAddress: 0.0.0.0
    featureGates: # 1. enable EndpointSliceProxying feature gate.
      EndpointSliceProxying: true
    clientConnection:
      acceptContentTypes: ""
      burst: 0
      contentType: ""
      #kubeconfig: /var/lib/kube-proxy/kubeconfig.conf # 2. comment this line.
      qps: 0
    clusterCIDR: 10.244.0.0/16
    configSyncPeriod: 0s
```

重启kube-proxy

```bash
kubectl delete po -n kube-system -l k8s-app=kube-proxy
```

参考：

- https://openyurt.io/zh/docs/user-manuals/network/service-topology
