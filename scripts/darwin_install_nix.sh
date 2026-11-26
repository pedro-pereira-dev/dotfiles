#!/usr/bin/env bash

darwin_install_nix() {
  if ! command -v nix >/dev/null 2>&1; then
    curl --proto '=https' --tlsv1.2 -L https://nixos.org/nix/install | sh
  fi
}
