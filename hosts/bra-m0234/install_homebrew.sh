#!/usr/bin/env bash

if ! log_check 'Checking if brew is installed' test -x /opt/homebrew/bin/brew; then
  log_start 'Installing' 'homebrew'
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  log_ok
fi

if ! log_check 'Checking if brew is in PATH' command -v brew; then
  log_info 'Activating shell environment with' 'homebrew'
  if [[ ":$PATH:" != *':/opt/homebrew/sbin:'* ]]; then
    export PATH="/opt/homebrew/sbin:$PATH"
  fi
  if [[ ":$PATH:" != *':/opt/homebrew/bin:'* ]]; then
    export PATH="/opt/homebrew/bin:$PATH"
  fi
fi
