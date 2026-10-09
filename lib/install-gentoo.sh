#!/usr/bin/env bash

install_gentoo_git() {
  if command -v git >/dev/null; then return 0; fi
  sudo emaint sync -A && sudo emerge --ask=n -1n dev-vcs/git && return 0
  return 1
}
