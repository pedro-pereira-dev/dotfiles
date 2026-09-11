#!/bin/bash
set -euo pipefail
_directory="$HOME/workspace/personal/dotfiles"
mkdir -p "$_directory"
bash -c "$(curl -fsSL get.chezmoi.io)" -- init --apply --source "$_directory" pedro-pereira-dev
