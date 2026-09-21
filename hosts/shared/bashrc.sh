#!/usr/bin/env bash

if [[ -x /opt/homebrew/bin/brew ]]; then
  [[ ":$PATH:" != *':/opt/homebrew/sbin:'* ]] && export PATH="/opt/homebrew/sbin:$PATH"
  [[ ":$PATH:" != *':/opt/homebrew/bin:'* ]] && export PATH="/opt/homebrew/bin:$PATH"
fi

[[ ":$PATH:" != *":$HOME/.local/bin:"* ]] && export PATH="$HOME/.local/bin:$PATH"
