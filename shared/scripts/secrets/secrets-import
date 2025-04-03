#!/bin/bash
set -eo pipefail

[[ ${EUID} -eq 0 ]] && echo 'Aborting... cannot run as root!' && exit 1
[[ ! -d /home/$(whoami)/workspace/personal/dotfiles-secrets ]] && echo 'Aborting... dotfiles-secrets was not cloned!' && exit 1

mkdir --parents "/home/$(whoami)/.ssh/secrets"
find "/home/$(whoami)/.ssh/secrets" -type f -name 'private.asc' -exec gpg --import '{}' ';'
gpg --fingerprint --list-keys |
  grep pub --after-context=1 |
  grep --extended-regexp --invert-match 'pub|--' |
  tr --delete ' ' |
  awk 'BEGIN { FS = "\n" } ; { print $1":6:" } ' |
  gpg --import-ownertrust
