#!/bin/bash

# sources profile on login shell
shopt -q login_shell && [ -f "${HOME}/.bashrc" ] && source ${HOME}/.bashrc
# loads hostname specific configurations
case $(uname -n) in
  gl-dell | gl-red)
    # [[ $(tty) == '/dev/tty1' && -z ${WAYLAND_DISPLAY} && ${XDG_VTNR} -eq 1 ]] && dbus-run-session Hyprland || true
    [[ -t 0 && $(tty) == '/dev/tty1' && ! $DISPLAY ]] && exec startx
  ;;
esac
