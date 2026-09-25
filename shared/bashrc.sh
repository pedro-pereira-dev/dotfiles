#!/usr/bin/env bash

if [[ -x /opt/homebrew/bin/brew ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi
if [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
  export PATH="$HOME/.local/bin:$PATH"
fi

command -v fnm >/dev/null && eval "$(fnm env --use-on-cd --shell bash)" || true

# fnm
FNM_PATH="/home/chuck/.local/share/fnm"
if [ -d "$FNM_PATH" ]; then
  export PATH="$FNM_PATH:$PATH"
  eval "$(fnm env --shell bash)"
fi

# opencode
export PATH=/home/chuck/.opencode/bin:$PATH
