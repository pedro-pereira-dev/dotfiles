#!/usr/bin/env bash

install_darwin_xcode() {
  if ! xcode-select --print-path >/dev/null 2>&1; then
    xcode-select --install || true
    until xcode-select --print-path >/dev/null 2>&1; do sleep 60; done
  fi
}

install_darwin_homebrew() {
  if [[ ! -x /opt/homebrew/bin/brew ]]; then NONINTERACTIVE=1 bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"; fi
  if ! command -v brew >/dev/null; then eval "$(/opt/homebrew/bin/brew shellenv)"; fi
}

install_darwin_git() {
  if ! brew list --formula git >/dev/null 2>&1; then brew install git; fi
}

install_darwin_bash() {
  if ! brew list --formula bash >/dev/null 2>&1; then brew install bash; fi
}

set_darwin_bash_shell() {
  local _bash=/opt/homebrew/bin/bash
  if ! grep -qxF "$_bash" /etc/shells; then printf '%s\n' "$_bash" | sudo tee -a /etc/shells >/dev/null; fi
  if ! dscl . -read "/Users/$USER" UserShell | grep -qxF "UserShell: $_bash"; then sudo chsh -s "$_bash" "$USER"; fi
}
