#!/bin/bash
set -eo pipefail

[[ $# -ne 1 ]] && echo "Usage: $(basename "$0") <font-name>" && exit 1
[[ -d ~/.fonts/$1 ]] && echo 'Aborting... nerd font already intalled!' && exit 0

TMP_FILE=$(mktemp)

wget --output-document="${TMP_FILE}" --quiet "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/$1.zip"
mkdir --parents ~/.fonts
unzip -d ~/.fonts/"$1" -q "${TMP_FILE}"
rm --force --recursive "${TMP_FILE}"
fc-cache -fr
