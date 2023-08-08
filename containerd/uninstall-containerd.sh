#!/bin/bash
set -ex

rm -fr /usr/local/bin/containerd* /usr/bin/containerd*
rm -fr /lib/systemd/system/containerd.service 
rm -fr /etc/containerd/

rm -fr /usr/local/bin/ctr /usr/bin/ctr
rm -fr /usr/local/bin/nerdctl /usr/bin/nerdctl
