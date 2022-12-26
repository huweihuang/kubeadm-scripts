## install openyurt control plane

```bash
bash helm-install-openyurt.sh {tunnelServerDomain} {tunnelServerPort}
```

## install yurthub

```bash
# create token
kubeadm token create

# exec script
bash install-yurthub.sh {custom_k8s_addr} {custom_token}
```
