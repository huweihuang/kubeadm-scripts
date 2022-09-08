#!/bin/bash
set -e

RuncVersion=$1
RuncVersion=${RuncVersion:-1.1.4}

echo "--------------backup runc--------------"
version=$(runc --version |grep version |awk '{print $3}')
runc_path=$(which runc)
mv ${runc_path} /usr/local/bin/runc.${version}

echo "--------------update runc--------------"
wget https://github.com/opencontainers/runc/releases/download/v${RuncVersion}/runc.amd64
chmod +x runc.amd64
mv runc.amd64 /usr/local/bin/runc

echo "--------------check version--------------"
runc --version
