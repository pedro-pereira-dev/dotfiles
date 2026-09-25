#!/usr/bin/env bash

install_xcode() {
  if ! xcode-select --print-path >/dev/null 2>&1; then
    xcode-select --install || true
    until xcode-select --print-path >/dev/null 2>&1; do sleep 60; done
  fi
}

install_homebrew() {
  if [[ ! -x /opt/homebrew/bin/brew ]]; then
    NONINTERACTIVE=1 \
      /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  fi
  if ! command -v brew >/dev/null; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  fi
}

install_git() {
  if ! brew list --formula git >/dev/null 2>&1; then
    brew install git
  fi
}
