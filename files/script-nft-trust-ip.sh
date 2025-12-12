#!/bin/sh
set -eou pipefail

run_as_root() {
  if [ "$(id -u)" -eq "$(id -u root)" ]; then
    "$@"
  elif command -v doas >/dev/null; then
    doas "$@"
  elif command -v sudo >/dev/null; then
    sudo "$@"
  fi
}

is_public_ip() {
  _is_public_ip_ip=$1
  case $_is_public_ip_ip in *.*.*.*) ;; *) return 1 ;; esac                                                 # invalid addresses
  case $_is_public_ip_ip in 0.* | 127.* | 169.254.*) return 1 ;; esac                                       # local networks
  case $_is_public_ip_ip in 10.* | 172.1[6-9].* | 172.2[0-9].* | 172.3[0-1].* | 192.168.*) return 1 ;; esac # rfc 1918

  _is_public_ip_ip_parts=$(printf '%s' "$_is_public_ip_ip" | tr '.' ' ') &&
    [ "$(echo "$_is_public_ip_ip_parts" | cut -d' ' -f1)" -lt 256 ] &&
    [ "$(echo "$_is_public_ip_ip_parts" | cut -d' ' -f2)" -lt 256 ] &&
    [ "$(echo "$_is_public_ip_ip_parts" | cut -d' ' -f3)" -lt 256 ] &&
    [ "$(echo "$_is_public_ip_ip_parts" | cut -d' ' -f4)" -lt 256 ]
}

[ $# -ne 1 ] && exit 1
_ip=$1
# && ! is_public_ip "$_ip" && exit 1
! rc-service nftables status 2>/dev/null | grep -q started && exit 1
run_as_root nft add element inet default trusted "{ $_ip }" || true
