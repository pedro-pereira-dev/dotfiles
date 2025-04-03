#!/bin/bash
set -eo pipefail

while [[ $# -gt 0 ]]; do
  case $1 in
  -h | --help) echo "Usage: $(basename "$0") --user <username> [--password <password>]" && exit 0 ;;
  --user) SYSTEM_USER=$2 ;;
  --password) PASSWORD=$2 ;;
  esac
  shift
  shift
done

[[ ${EUID} -ne 0 ]] && su root -c "$0" "$@" && exit $?
[[ -z ${SYSTEM_USER} ]] && exit 1

if [[ -z ${PASSWORD} ]]; then
  while true; do
    echo "Setting up system password for ${SYSTEM_USER}:"
    read -r -s -p ' - Password: ' PASSWORD && echo ''
    read -r -s -p ' - Confirm password: ' PASSWORD_CONFIRMATION && echo ''
    [[ "${PASSWORD}" == "${PASSWORD_CONFIRMATION}" ]] && echo '' && break
    echo -e '\nPasswords do not match!'
  done
fi

useradd --create-home --shell /bin/bash "${SYSTEM_USER}"
usermod --append --groups wheel "${SYSTEM_USER}"
chown --changes --recursive "${SYSTEM_USER}:${SYSTEM_USER}" "/home/${SYSTEM_USER}"
echo "${SYSTEM_USER}:${PASSWORD}" | chpasswd
