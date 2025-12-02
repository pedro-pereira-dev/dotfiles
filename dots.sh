#!/bin/sh
# shellcheck disable=SC2015,SC2329 source=/dev/null
set -eou pipefail

set -x

is_linux() { test "$(uname)" = Linux; }
is_macos() { test "$(uname)" = Darwin; }

is_user() { test "$(id -u)" -eq "$(id -u "$1")"; }
is_root() { is_user root; }

run_as_root() { if is_root; then "$@"; elif command -v doas >/dev/null; then doas "$@"; elif command -v sudo >/dev/null; then sudo "$@"; fi; }
run_as_user() { _USER=$1 && shift && if is_user "$_USER"; then "$@"; else run_as_root su "$_USER" -c "$(printf '%s ' "$@")"; fi; }

link_as_root() { run_as_root rm -fr "$2" && run_as_root mkdir -p "$(dirname "$2")" && run_as_root ln -fsv "$1" "$2"; }
link_as_user() { _USER=$1 && shift && run_as_user "$_USER" rm -fr "$2" && run_as_user "$_USER" mkdir -p "$(dirname "$2")" && run_as_user "$_USER" ln -fsv "$1" "$2"; }

delete_links() {
  _DIR=$1 && shift && "$@" find "$_DIR" -type l 2>/dev/null | while IFS= read -r _ENTRY; do # lists links
    case $_ENTRY in */lost+found/* | /boot/* | /dev/* | /efi/* | /media/* | /mnt/*) continue ;; esac
    case $_ENTRY in /opt/* | /proc/* | /run/* | /sys/* | /tmp/* | /var/*) continue ;; esac
    "$@" find "$_ENTRY" -printf '%l\n' 2>/dev/null | while IFS= read -r _PATH; do # resolves link
      case $_PATH in */dotfiles/*) rm -v "$_ENTRY" && rmdir -pv "$(dirname "$_ENTRY")" 2>/dev/null ;; esac
    done
  done
}
delete_links_as_root() { delete_links / run_as_root; }
delete_links_as_user() { _USER=$1 && _DIR=$2 && delete_links "$_DIR" run_as_user "$_USER"; }

create_user() { _USER=$1 && ! id "$_USER" >/dev/null 2>&1 && run_as_root useradd -ms /usr/bin/bash "$_USER"; }
setup_doas() { _CONF=$1 && { ! command -v doas >/dev/null && run_as_root emerge --ask=n -n app-admin/doas || true; } &&
  run_as_root cp -f "$_CONF" /etc/doas.conf && run_as_root chown root:root /etc/doas.conf && run_as_root chmod 0600 /etc/doas.conf &&
  run_as_root passwd -dl root >/dev/null; }

get_home() { _USER=$1 && { is_linux && echo "/home/$_USER"; } || { is_macos && echo "/Users/$_USER"; }; }
get_wheel_user() { is_root && grep ^wheel: /etc/group | cut -d, -f2 | grep -v root || whoami; }

get_parameter() {
  _FLAG=$1 && shift && while [ $# -ge 1 ]; do
    _PARAM=$1 && shift && [ "$_FLAG" = "$_PARAM" ] && {
      _VAL='' && [ $# -ge 1 ] && _VAL=$1
      [ -n "$_VAL" ] && expr "x$_VAL" : 'x[^-]' >/dev/null && echo "$_VAL" || true # prints out if not starting by -
    } && return 0
  done && return 1
}

dots_bootstrap() {
  _USER=$1 && shift && _HOME=$(get_home "$_USER") || return 1
  [ -d "$_HOME/workspace/personal/dotfiles/.git" ] && return 0
  run_as_user "$_USER" mkdir -p "$_HOME/workspace/personal"
  run_as_user "$_USER" rm -fr "$_HOME/workspace/personal/dotfiles"
  run_as_user "$_USER" git clone https://github.com/pedro-pereira-dev/dotfiles.git "$_HOME/workspace/personal/dotfiles"
}
dots_update() {
  _USER=$1 && shift && _HOME=$(get_home "$_USER") || return 1
  run_as_user "$_USER" git -C "$_HOME/workspace/personal/dotfiles" fetch origin || return 1
  run_as_user "$_USER" git -C "$_HOME/workspace/personal/dotfiles" reset --hard origin/main || return 1
  run_as_user "$_USER" git -C "$_HOME/workspace/personal/dotfiles" clean -dfqx
}
dots_sync() {
  _HOSTNAME=$1 && shift && _USER=$1 && shift && _HOME=$(get_home "$_USER") || return 1
  . "$_HOME/workspace/personal/dotfiles/hosts/$_HOSTNAME/$_HOSTNAME.sh" && configure "$@"
}

_HOSTNAME=$(get_parameter --hostname "$@") && [ -n "$_HOSTNAME" ] || _HOSTNAME=$(hostname) ||
  { echo '[E] missing required argument --hostname' && exit 1; }
_USER=$(get_parameter --user "$@") && [ -n "$_USER" ] || _USER=$(get_wheel_user) ||
  { echo '[E] missing required argument --user' && exit 1; }
[ "$#" -ge 1 ] && _CMD=$1 && shift && case $_CMD in

update) dots_bootstrap "$_USER" && dots_update "$_USER" || exit 1 ;;
sync) dots_bootstrap "$_USER" && dots_sync "$_HOSTNAME" "$_USER" "$@" || exit 1 ;;
*) exit 1 ;; esac && exit 0
