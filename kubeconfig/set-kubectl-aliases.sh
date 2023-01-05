#!/bin/bash
set -ex

wget https://raw.githubusercontent.com/ahmetb/kubectl-aliases/master/.kubectl_aliases -P ${HOME}

cat >> ${HOME}/.bashrc << EOF

# kubectl alias setting
[ -f ~/.kubectl_aliases ] && source ~/.kubectl_aliases
function kubectl() { command kubectl \$@; }
EOF

source ${HOME}/.bashrc
