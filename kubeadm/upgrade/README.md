# 升级master节点

升级master节点，需要先升级master组件，包括etcd， 再升级kubelet组件。

```bash
# 第一个master节点
bash upgrade-master.sh <version> first

# 其他master节点
bash upgrade-master.sh <version>
```

# 升级worker节点

升级worker节点，只需要升级kubelet组件。

```bash
bash update-kubelet.sh <version>
```
