#!/bin/sh
set -eou pipefail

is_root() { test "$(id -u)" -eq 0; }

run_as_root() { if is_root; then "$@"; elif check_command doas; then doas sh -c "$*"; elif check_command sudo; then sudo sh -c "$*"; fi; }

[ ! -d /var/db/repos/gentoo/.git ] && run_as_root rm -fr /var/db/repos/gentoo
run_as_root emaint sync -A
