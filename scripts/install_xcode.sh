#!/usr/bin/env bash

if ! xcode-select --print-path >/dev/null; then
  xcode-select --install || true
  until xcode-select --print-path >/dev/null 2>&1; do sleep 60; done
fi
