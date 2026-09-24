#!/usr/bin/env bash

if ! log_check 'Checking if git is installed' command -v git; then
  log_start 'Installing' 'git'
  sudo apt update
  sudo apt install -y git
  log_ok
fi
