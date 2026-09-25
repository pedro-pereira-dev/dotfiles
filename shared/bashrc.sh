#!/usr/bin/env bash

if [[ -x /opt/homebrew/bin/brew ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi
if [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
  export PATH="$HOME/.local/bin:$PATH"
fi

# fnm
if [[ -d $HOME/.local/share/fnm ]]; then
  export PATH="$HOME/.local/share/fnm:$PATH"
fi
if command -v fnm >/dev/null; then
  eval "$(fnm env --use-on-cd --shell bash)"
fi

# opencode
if [[ -d $HOME/.opencode/bin ]]; then
  export PATH="$HOME/.opencode/bin:$PATH"
fi
