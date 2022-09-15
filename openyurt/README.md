## install yurthub

```bash
# update __custom_k8s_addr__ and __custom_token__
sed -i 's|__k8s_addr__|__custom_k8s_addr__|;
s|__token__|__custom_token__|' install-yurthub.sh

# exec script
bash install-yurthub.sh
```
