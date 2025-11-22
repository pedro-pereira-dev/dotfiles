#!/bin/sh
set -eou pipefail

_HOSTNAME=gv-test

configure() {
  setup_doas
  get_parameter --full "$@" >/dev/null && delete_links_as_root
  link_as_root "$_HOME/workspace/personal/dotfiles/dots.sh" /usr/bin/dots

  run_as_root rc-update add sshd default >/dev/null

  return 0
}
