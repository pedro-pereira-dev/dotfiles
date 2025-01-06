#!/bin/bash

set -e

THIS_SCRIPT_DIR=$(dirname "$0")
THIS_SYSTEM=$(uname -s)

if [[ -z $(command -v "command-check") ]]; then
  echo "Missing command(s): command-check"
  exit 1
fi

command-check nvim stow vscode

stow --force "${THIS_SCRIPT_DIR}"/neovim "${HOME}"/.config/nvim
stow --force "${THIS_SCRIPT_DIR}"/resources "${HOME}"/.config/
stow --force "${THIS_SCRIPT_DIR}"/scripts "${HOME}"/.local/bin
if [[ "${THIS_SYSTEM}" == "Darwin" ]]; then
  stow --force "${THIS_SCRIPT_DIR}"/vscode "${HOME}"/Library/Application\ Support/Code/User
elif [[ "${THIS_SYSTEM}" == "Linux" ]]; then
  stow --force "${THIS_SCRIPT_DIR}"/vscode "${HOME}"/.config/Code/User
fi
