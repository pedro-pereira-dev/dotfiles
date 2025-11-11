#!/bin/bash

[[ $# -gt 1 ]] && echo "Usage: $(basename "$0") [--unsupervised]" && exit 1
[[ ! -d /etc/portage/package.declare ]] && echo 'Aborting... missing configuration file: /etc/portage/package.declare!' && exit 1
[[ ! -f /var/lib/portage/world ]] && echo 'Aborting... missing configuration file: /var/lib/portage/world!' && exit 1
if [[ ${EUID} -ne 0 ]]; then
  doas "$0" "$@"
  exit $?
fi

INSTALLED_DEPENDENCIES=$(cat /var/lib/portage/world)
DECLARED_DEPENDENCIES=$(cat /etc/portage/package.declare/* | sort -u | sed -E -e '/^[[:space:]]*#/d' -e 's/([[:space:]])+#.*$//')
ALL_DEPENDENCIES=$(echo "${INSTALLED_DEPENDENCIES} ${DECLARED_DEPENDENCIES}" | tr ' ' '\n' | sort | uniq)

function is_declared { grep --quiet "^$1$" <<<"${DECLARED_DEPENDENCIES}"; }
function is_installed { grep --quiet "^$1$" <<<"${INSTALLED_DEPENDENCIES}"; }

declare -a INSTALL=()
declare -a REMOVE=()

for DEPENDENCY in ${ALL_DEPENDENCIES}; do
  if ! is_installed "${DEPENDENCY}" && is_declared "${DEPENDENCY}"; then
    INSTALL+=("${DEPENDENCY}")
  elif is_installed "${DEPENDENCY}" && ! is_declared "${DEPENDENCY}"; then
    REMOVE+=("${DEPENDENCY}")
  fi
done

[[ ${#INSTALL[@]} -ne 0 ]] && emerge --ask="$([[ $1 == '--unsupervised' ]] && echo 'n' || echo 'y')" "${INSTALL[@]}"
[[ ${#REMOVE[@]} -ne 0 ]] && emerge --ask="$([[ $1 == '--unsupervised' ]] && echo 'n' || echo 'y')" --deselect "${REMOVE[@]}"
