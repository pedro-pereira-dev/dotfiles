#!/usr/bin/env bash

install_gentoo_git() { if ! command -v git >/dev/null; then emerge --ask=n -1n dev-vcs/git; fi; }
