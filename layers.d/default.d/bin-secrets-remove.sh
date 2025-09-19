#!/bin/bash
set -eo pipefail

[[ ${EUID} -eq 0 ]] && echo 'Aborting... cannot run as root!' && exit 1
[[ $# -ne 1 ]] && echo "Usage: $(basename "$0") <secret-name>" && exit 1
[[ ! -d /home/$(whoami)/workspace/personal/dotfiles-secrets ]] && echo 'Aborting... dotfiles-secrets was not cloned!' && exit 1
[[ ! -d /home/$(whoami)/.ssh/secrets/$1 ]] && echo "Aborting... /home/$(whoami)/.ssh/secrets/$1 does not exist!" && exit 1

if [[ -f /home/$(whoami)/.ssh/secrets/$1/private.asc ]]; then
  GPG_KEY=$(gpg --dry-run --import-options import-show --with-colons \
    --import "/home/$(whoami)/.ssh/secrets/$1/private.asc" 2>&1 |
    grep --only-matching --perl-regexp 'fpr:*\K(.*)(?=:)')

  if [[ -n ${GPG_KEY} ]]; then
    if gpg --list-keys | grep --only-matching --perl-regexp "${GPG_KEY}" >/dev/null; then
      gpg --batch --delete-secret-key --yes --pinentry-mode loopback "${GPG_KEY}"
      gpg --batch --delete-key --yes --pinentry-mode loopback "${GPG_KEY}"
    fi
  fi
fi
rm --force --recursive "/home/$(whoami)/.ssh/secrets/$1"
