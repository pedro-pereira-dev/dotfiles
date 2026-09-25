#!/usr/bin/env bash

if ! xcode-select --print-path; then
  printf '\n%s\n' 'Installing xcode'
  xcode-select --install || true
  until xcode-select --print-path >/dev/null 2>&1; do sleep 60; done
fi
