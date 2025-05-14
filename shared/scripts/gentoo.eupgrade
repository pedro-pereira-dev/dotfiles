#!/bin/bash

[[ $# -gt 1 ]] && echo "Usage: $(basename "$0") [--unsupervised]" && exit 1
if [[ ${EUID} -ne 0 ]]; then
  doas "$0" "$@"
  exit $?
fi

ASK=$([[ $1 == '--unsupervised' ]] && echo 'n' || echo 'y')
emerge --ask="${ASK}" --backtrack=30 --deep --newuse --update --verbose --with-bdeps=y @world
