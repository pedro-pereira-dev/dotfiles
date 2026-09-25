#!/usr/bin/env bash
set -euo pipefail

if [[ ! -x /opt/homebrew/bin/brew ]]; then
  NONINTERACTIVE=1 \
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

if ! command -v brew >/dev/null; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi
