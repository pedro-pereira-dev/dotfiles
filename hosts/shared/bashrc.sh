#!/usr/bin/env bash

if [[ -x /opt/homebrew/bin/brew ]]; then
  if [[ ":$PATH:" != *':/opt/homebrew/sbin:'* ]]; then
    export PATH="/opt/homebrew/sbin:$PATH"
  fi
  if [[ ":$PATH:" != *':/opt/homebrew/bin:'* ]]; then
    export PATH="/opt/homebrew/bin:$PATH"
  fi
fi

if [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
  export PATH="$HOME/.local/bin:$PATH"
fi
