#!/bin/sh
# shellcheck disable=SC2015,SC2329 source=/dev/null
set -eou pipefail

set -x

is_linux() { test "$(uname)" = Linux; }
is_macos() { test "$(uname)" = Darwin; }

is_user() { _user=$1 && test "$(id -u)" -eq "$(id -u "$_user")"; }
is_root() { is_user root; }

run_as_root() { if is_root; then "$@"; elif command -v doas >/dev/null; then doas "$@"; elif command -v sudo >/dev/null; then sudo "$@"; fi; }
run_as_user() { _user=$1 && shift && if is_user "$_user"; then "$@"; else run_as_root su "$_user" -c "$(printf '%s ' "$@")"; fi; }

link_as_root() { _source=$1 && _target=$2 &&
  run_as_root rm -fr "$_target" && run_as_root mkdir -p "$(dirname "$_target")" &&
  run_as_root ln -fsv "$_source" "$_target"; }
link_as_user() { _user=$1 && _source=$2 && _target=$3 &&
  run_as_user "$_user" rm -fr "$_target" && run_as_user "$_user" mkdir -p "$(dirname "$_target")" &&
  run_as_user "$_user" ln -fsv "$_source" "$_target"; }

delete_links() {
  _dir=$1 && shift && "$@" find "$_dir" -type l 2>/dev/null | while IFS= read -r _entry; do # lists links
    # matches entries to ignore, usually system directories
    case $_entry in /boot/* | /dev/* | /efi/* | /media/* | /mnt/*) continue ;; esac
    case $_entry in /opt/* | /proc/* | /run/* | /sys/* | /tmp/* | /var/*) continue ;; esac
    case $_entry in /etc/pam.d/* | /etc/runlevels/* | /etc/ssl/*) continue ;; esac
    case $_entry in /usr/*-linux-*/* | /usr/include/* | /usr/lib/* | /usr/lib64/*) continue ;; esac
    case $_entry in /usr/libexec/* | /usr/local/* | /usr/share/* | /usr/src/*) continue ;; esac
    case $_entry in */lost+found/* | */.local/share/containers/*) continue ;; esac
    # resolves link, deletes it and deletes all parent directories if empty
    "$@" find "$_entry" -printf '%l\n' 2>/dev/null | while IFS= read -r _path; do
      case $_path in */dotfiles/*) "$@" rm "$_entry" && echo "'$_entry' X" && "$@" rmdir -p "$(dirname "$_entry")" 2>/dev/null ;; esac
    done
  done
}
delete_links_as_root() { delete_links / run_as_root; }
delete_links_as_user() { _user=$1 && _dir=$2 && delete_links "$_dir" run_as_user "$_user"; }

setup_doas() { _conf=$1 && { ! command -v doas >/dev/null && run_as_root emerge --ask=n -n app-admin/doas || true; } &&
  run_as_root cp -f "$_conf" /etc/doas.conf && run_as_root chown root:root /etc/doas.conf && run_as_root chmod u=rw /etc/doas.conf &&
  run_as_root passwd -dl root >/dev/null; }

get_home() { _user=$1 && { is_linux && echo "/home/$_user"; } || { is_macos && echo "/Users/$_user"; }; }
get_wheel_user() { is_root && grep ^wheel: /etc/group | cut -d, -f2 | grep -v root || whoami; }

get_parameter() {
  _flag=$1 && shift && while [ $# -ge 1 ]; do
    _param=$1 && shift && [ "$_flag" = "$_param" ] && {
      _val='' && [ $# -ge 1 ] && _val=$1
      [ -n "$_val" ] && expr "x$_val" : 'x[^-]' >/dev/null && echo "$_val" || true # prints out if not starting by -
    } && return 0
  done && return 1
}

dots_bootstrap() {
  _user=$1 && _home=$(get_home "$_user") || return 1
  [ -d "$_home/workspace/personal/dotfiles/.git" ] && return 0
  run_as_user "$_user" mkdir -p "$_home/workspace/personal"
  run_as_user "$_user" rm -fr "$_home/workspace/personal/dotfiles"
  run_as_user "$_user" git clone https://github.com/pedro-pereira-dev/dotfiles.git "$_home/workspace/personal/dotfiles"
}
dots_update() {
  _user=$1 && _home=$(get_home "$_user") || return 1
  run_as_user "$_user" git -C "$_home/workspace/personal/dotfiles" fetch origin || return 1
  run_as_user "$_user" git -C "$_home/workspace/personal/dotfiles" reset --hard origin/main || return 1
  run_as_user "$_user" git -C "$_home/workspace/personal/dotfiles" clean -dfqx
}
dots_sync() {
  _hostname=$1 && shift && _user=$1 && shift && _home=$(get_home "$_user") || return 1
  . "$_home/workspace/personal/dotfiles/hosts/$_hostname/$_hostname.sh" && configure "$@"
}

_HOSTNAME=$(get_parameter --hostname "$@") && [ -n "$_HOSTNAME" ] || _HOSTNAME=$(hostname) ||
  { echo '[E] missing required argument --hostname' && exit 1; }
_USER=$(get_parameter --user "$@") && [ -n "$_USER" ] || _USER=$(get_wheel_user) ||
  { echo '[E] missing required argument --user' && exit 1; }
[ "$#" -ge 1 ] && _CMD=$1 && shift && case $_CMD in

update) dots_bootstrap "$_USER" && dots_update "$_USER" || exit 1 ;;
sync) dots_bootstrap "$_USER" && dots_sync "$_HOSTNAME" "$_USER" "$@" || exit 1 ;;

*) exit 1 ;; esac && exit 0
