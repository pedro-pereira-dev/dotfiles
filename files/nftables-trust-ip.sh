#!/bin/sh
set -eou pipefail

is_root() { test "$(id -u)" -eq 0; }
run_as_root() { if is_root; then "$@"; elif command -v doas >/dev/null; then doas "$@"; elif command -v sudo >/dev/null; then sudo "$@"; fi; }

is_public_ip() {
  case $1 in *.*.*.*) ;; *) return 1 ;; esac                                                 # invalid addresses
  case $1 in 0.* | 127.* | 169.254.*) return 1 ;; esac                                       # local networks
  case $1 in 10.* | 172.1[6-9].* | 172.2[0-9].* | 172.3[0-1].* | 192.168.*) return 1 ;; esac # rfc 1918

  _IP=$(printf '%s' "$1" | tr '.' ' ') &&
    [ "$(echo "$_IP" | cut -d' ' -f1)" -lt 256 ] &&
    [ "$(echo "$_IP" | cut -d' ' -f2)" -lt 256 ] &&
    [ "$(echo "$_IP" | cut -d' ' -f3)" -lt 256 ] &&
    [ "$(echo "$_IP" | cut -d' ' -f4)" -lt 256 ] &&
    return 0

  return 1
}

[ $# -lt 1 ] && exit 1
is_public_ip "$1" && run_as_root nft add element inet default trusted "{ $1 }"
exit 0
