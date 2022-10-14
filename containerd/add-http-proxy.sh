#!/bin/bash
set -e

ProxyAddr=$1

# add http_proxy env to containerd
mkdir -p /lib/systemd/system/containerd.service.d
cat > /lib/systemd/system/containerd.service.d/http-proxy.conf << EOF
[Service]
Environment="HTTP_PROXY=http://${ProxyAddr}/"
Environment="HTTPS_PROXY=http://${ProxyAddr}/"
EOF

systemctl daemon-reload
systemctl restart containerd
systemctl show --property=Environment containerd
