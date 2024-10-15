#!/bin/bash

# sourced by bash login shells
shopt -q login_shell && [ -f "${HOME}/.bashrc" ] && source ${HOME}/.bashrc

# loads hostname specific configurations
case $(uname -n) in
gentoo-laptop-msi-es)
  # starts hyprland
  [[ $(tty) == '/dev/tty1' && -z ${WAYLAND_DISPLAY} && ${XDG_VTNR} -eq 1 ]] && dbus-run-session Hyprland || true
  ;;
esac
