#!/usr/bin/env bash

darwin_install_xcode() {
  if ! xcode-select --print-path >/dev/null 2>&1; then
    xcode-select --install || true
    until xcode-select --print-path >/dev/null 2>&1; do sleep 60; done
  fi
}
