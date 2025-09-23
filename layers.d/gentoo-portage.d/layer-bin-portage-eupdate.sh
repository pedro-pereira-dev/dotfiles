#!/bin/bash
set -eou pipefail

[[ $# -gt 0 ]] && echo "Usage: $(basename "$0")" && exit 1
if [[ ${EUID} -ne 0 ]]; then
  doas "$0" "$@"
  exit $?
fi

[ ! -d '/var/db/repos/gentoo/.git' ] && rm -fr /var/db/repos/gentoo || true
emaint sync --allrepos
