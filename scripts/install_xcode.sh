#!/usr/bin/env bash

if ! log_check 'Checking if xcode is installed' xcode-select --print-path; then
  log_start 'Installing' 'xcode'
  xcode-select --install >/dev/null 2>&1 || true
  until xcode-select --print-path >/dev/null 2>&1; do sleep 60; done
  log_ok
fi
