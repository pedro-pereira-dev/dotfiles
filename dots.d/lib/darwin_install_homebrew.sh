#!/usr/bin/env bash

darwin_install_homebrew() {
  if [[ ! -x /opt/homebrew/bin/brew ]]; then NONINTERACTIVE=1 \
    bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"; fi
  if [[ ":$PATH:" != *":/opt/homebrew/bin:"* ]]; then export PATH="/opt/homebrew/bin:/opt/homebrew/sbin:$PATH"; fi
}
