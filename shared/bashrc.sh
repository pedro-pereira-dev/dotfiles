#!/usr/bin/env bash

_prepend_path() { if [[ -d $1 && ":$PATH:" != *":$1:"* ]]; then export PATH="$1:$PATH"; fi; }
_prepend_path /opt/homebrew/sbin
_prepend_path /opt/homebrew/bin
_prepend_path "$HOME/.local/bin"

# fnm
_prepend_path "$HOME/.local/share/fnm"
if command -v fnm >/dev/null; then
  eval "$(fnm env --use-on-cd --shell bash)"
fi

# opencode
_prepend_path "$HOME/.opencode/bin"

unset -f _prepend_path
