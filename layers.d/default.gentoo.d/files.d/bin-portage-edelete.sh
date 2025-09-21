#!/bin/bash
[[ $# -gt 1 ]] && echo "Usage: $(basename "$0") [--unsupervised]" && exit 1
if [[ ${EUID} -ne 0 ]]; then
  doas "$0" "$@"
  exit $?
fi
emerge --ask="$([[ $1 == '--unsupervised' ]] && echo 'n' || echo 'y')" --depclean
command -v eclean-dist >/dev/null 2>&1 && eclean-dist --deep
command -v eclean-pkg >/dev/null 2>&1 && eclean-pkg --deep
command -v eclean-kernel >/dev/null 2>&1 && eclean-kernel -n 2
