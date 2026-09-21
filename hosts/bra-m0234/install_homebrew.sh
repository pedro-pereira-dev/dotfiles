#!/usr/bin/env bash

if ! log_check 'Checking if brew is installed' test -x /opt/homebrew/bin/brew; then
  log_check 'Checking if xcode is installed' xcode-select --print-path || return
  log_start 'Installing' 'homebrew'
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  log_ok
fi

if ! log_check 'Checking if brew is in PATH' command -v brew; then
  log_info 'Activating shell environment with' 'homebrew'
  [[ ":$PATH:" != *':/opt/homebrew/sbin:'* ]] && export PATH="/opt/homebrew/sbin:$PATH"
  [[ ":$PATH:" != *':/opt/homebrew/bin:'* ]] && export PATH="/opt/homebrew/bin:$PATH"
fi
