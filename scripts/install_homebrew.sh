#!/usr/bin/env bash

if [[ ! -x /opt/homebrew/bin/brew ]]; then
  printf '\n%s\n' 'Installing homebrew'
  NONINTERACTIVE=1 \
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

if ! command -v brew >/dev/null; then
  printf '\n%s\n' 'Activating shell environment with homebrew'
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi
