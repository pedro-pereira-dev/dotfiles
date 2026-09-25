#!/usr/bin/env bash

if ! command -v git >/dev/null; then
  printf '\n%s\n' 'Installing git'
  brew install git
fi
