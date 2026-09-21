#!/usr/bin/env bash

if ! log_check 'Checking if git is installed' command -v git; then
  log_start 'Installing' 'git'
  log_check 'Checking if brew is available' command -v brew || return
  brew install git
  log_ok
fi
