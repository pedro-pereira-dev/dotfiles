#!/bin/bash

[[ $# -gt 1 ]] && echo "Usage: $(basename "$0") [--unsupervised]" && exit 1
if [[ ${EUID} -ne 0 ]]; then
  doas "$0" "$@"
  exit $?
fi

eupdate
eupgrade "$([[ $1 == '--unsupervised' ]] && echo '--unsupervised' || echo '')"
edeclare "$([[ $1 == '--unsupervised' ]] && echo '--unsupervised' || echo '')"
edelete "$([[ $1 == '--unsupervised' ]] && echo '--unsupervised' || echo '')"
