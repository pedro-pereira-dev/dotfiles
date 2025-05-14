#!/bin/bash

[[ $# -gt 0 ]] && echo "Usage: $(basename "$0")" && exit 1
if [[ ${EUID} -ne 0 ]]; then
  doas "$0" "$@"
  exit $?
fi

emaint sync --allrepos
