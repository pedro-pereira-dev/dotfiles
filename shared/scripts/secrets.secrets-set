#!/bin/bash
set -eo pipefail

[[ ${EUID} -eq 0 ]] && echo 'Aborting... cannot run as root!' && exit 1
[[ $# -ne 1 ]] && echo "Usage: $(basename "$0") <secret-name>" && exit 1
[[ ! -d /home/$(whoami)/workspace/personal/dotfiles-secrets ]] && echo 'Aborting... dotfiles-secrets was not cloned!' && exit 1
[[ -d /home/$(whoami)/.ssh/secrets/$1 ]] && echo "Aborting... /home/$(whoami)/.ssh/secrets/$1 already exists!" && exit 0
[[ ! -f /home/$(whoami)/workspace/personal/dotfiles-secrets/$1.tar.enc ]] &&
  echo "Aborting... /home/$(whoami)/workspace/personal/dotfiles-secrets/$1.tar.enc does not exist!" && exit 1

SECRET_TAR=$(mktemp)

mkdir --parents "/home/$(whoami)/.ssh/secrets"
while true; do
  echo "Setting up /home/$(whoami)/workspace/personal/dotfiles-secrets/$1.tar.enc: "
  read -r -p ' - Password: ' PASSWORD && echo ''
  gpg --batch --passphrase "${PASSWORD}" --pinentry-mode loopback --quiet \
    --decrypt "/home/$(whoami)/workspace/personal/dotfiles-secrets/$1.tar.enc" >"${SECRET_TAR}" && break
  echo -e '\nPassword is not correct!'
done
tar --directory "/home/$(whoami)/.ssh/secrets" --extract --file "${SECRET_TAR}"
rm --force "${SECRET_TAR}"
