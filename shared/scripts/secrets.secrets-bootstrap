#!/bin/bash
set -eo pipefail

[[ ${EUID} -eq 0 ]] && echo 'Aborting... cannot run as root!' && exit 1

DOTFILES_SECRETS_DIR="/home/$(whoami)/workspace/personal/dotfiles-secrets"
DOTFILES_SECRETS_REPOSITORY="https://github.com/pedro-pereira-dev/dotfiles-secrets"

if [[ ! -d ${DOTFILES_SECRETS_DIR} ]]; then
  mkdir --parents "$(dirname "${DOTFILES_SECRETS_DIR}")"
  while true; do
    echo "Setting up git clone for ${DOTFILES_SECRETS_REPOSITORY}:"
    read -r -p ' - Access token: ' SECRET_TOKEN && echo ''
    git clone ${DOTFILES_SECRETS_REPOSITORY/:\/\//:\/\/oauth2:${SECRET_TOKEN}@} "${DOTFILES_SECRETS_DIR}" 2>/dev/null && break
    echo "Secret ${SECRET_TOKEN} is unauthorized!"
  done
fi

cd "${DOTFILES_SECRETS_DIR}"
git fetch origin
git reset --hard origin/main
git clean --force --quiet -dx
