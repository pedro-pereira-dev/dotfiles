#!/bin/bash
set -eo pipefail

while [[ $# -gt 0 ]]; do
  case $1 in
  -h | --help) echo "Usage: $(basename "$0") [--hostname <hostname>] [--user <username>] [--password <password>]" && exit 0 ;;
  --hostname) SYSTEM_HOSTNAME=$2 ;;
  --user) SYSTEM_USER=$2 ;;
  --password) PASSWORD=$2 ;;
  esac
  shift
  shift
done

function run_as_user() { if [[ ${EUID} -eq 0 ]]; then runuser --user="$1" -- "${@:2}"; else "${@:2}"; fi; }

SYSTEM_HOSTNAME=${SYSTEM_HOSTNAME:-$(uname --nodename)}
SYSTEM_USER=${SYSTEM_USER:-'chuck'}

DOTFILES_DIR="/home/${SYSTEM_USER}/workspace/personal/dotfiles"
DOTFILES_REPOSITORY="https://github.com/pedro-pereira-dev/dotfiles"

if [[ -n ${SYSTEM_USER} ]]; then
  if ! grep "${SYSTEM_USER}" /etc/passwd >/dev/null 2>&1; then
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
  fi
fi

! command -v git >/dev/null 2>&1 && emerge --ask=n --noreplace dev-vcs/git
run_as_user "${SYSTEM_USER}" mkdir --parents "$(dirname "${DOTFILES_DIR}")"
run_as_user "${SYSTEM_USER}" git -C "${DOTFILES_DIR}" status >/dev/null 2>&1 || run_as_user "${SYSTEM_USER}" git clone ${DOTFILES_REPOSITORY} "${DOTFILES_DIR}"
bash "${DOTFILES_DIR}/ecare" --hostname "${SYSTEM_HOSTNAME}" --user "${SYSTEM_USER}"
