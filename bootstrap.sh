#!/bin/bash
set -eo pipefail

while [[ $# -gt 0 ]]; do
  case $1 in
  -h | --help) echo "Usage: $(basename "$0") --hostname <hostname> --user <username> [--password <password>]" && exit 0 ;;
  --hostname) SYSTEM_HOSTNAME=$2 ;;
  --user) SYSTEM_USER=$2 ;;
  --password) PASSWORD=$2 ;;
  esac
  shift
  shift
done

[[ ${EUID} -ne 0 ]] && su root -c "$0" "$@" && exit $?
[[ -z ${SYSTEM_HOSTNAME} || -z ${SYSTEM_USER} ]] && exit 1
[[ -n ${SYSTEM_USER} ]] && ! grep "${SYSTEM_USER}" /etc/passwd >/dev/null 2>&1 &&
  bash <(wget -qO- https://raw.githubusercontent.com/pedro-pereira-dev/gentoo-installer/refs/heads/main/add_wheel_user.sh) \
    --user "${SYSTEM_USER}" --password "${PASSWORD}"

! command -v git >/dev/null 2>&1 && emerge --ask=n --noreplace dev-vcs/git
su "${SYSTEM_USER}" -c "mkdir --parents /home/${SYSTEM_USER}/workspace/personal"
[[ ! -d /home/${SYSTEM_USER}/workspace/personal/dotfiles ]] &&
  su "${SYSTEM_USER}" -c "git clone https://github.com/pedro-pereira-dev/dotfiles /home/${SYSTEM_USER}/workspace/personal/dotfiles"
"/home/${SYSTEM_USER}/workspace/personal/dotfiles/ecare" \
  --hostname "${SYSTEM_HOSTNAME}" --user "${SYSTEM_USER}"
