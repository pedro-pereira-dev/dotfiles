#!/bin/sh
# shellcheck disable=SC2015,SC2329 source=/dev/null
set -eou pipefail

is_linux() { test "$(uname)" = Linux; }
is_macos() { test "$(uname)" = Darwin; }

is_user() { _is_user_user=$1 && test "$(id -u)" -eq "$(id -u "$_is_user_user")"; }
is_root() { is_user root; }

run_as_root() {
  if is_root; then
    "$@"
  elif command -v doas >/dev/null; then
    doas "$@"
  elif command -v sudo >/dev/null; then
    sudo "$@"
  fi
}
run_as_user() {
  _run_as_user_user=$1 && shift
  if is_user "$_run_as_user_user"; then
    "$@"
  else
    run_as_root su "$_run_as_user_user" -c "$(printf '%s ' "$@")"
  fi
}

link_as_root() { _link_as_root_source=$1 && _link_as_root_target=$2 &&
  run_as_root rm -fr "$_link_as_root_target" &&
  run_as_root mkdir -p "$(dirname "$_link_as_root_target")" &&
  run_as_root ln -fsv "$_link_as_root_source" "$_link_as_root_target"; }
link_as_user() { _link_as_user_user=$1 && _link_as_user_source=$2 && _link_as_user_target=$3 &&
  run_as_user "$_link_as_user_user" rm -fr "$_link_as_user_target" &&
  run_as_user "$_link_as_user_user" mkdir -p "$(dirname "$_link_as_user_target")" &&
  run_as_user "$_link_as_user_user" ln -fsv "$_link_as_user_source" "$_link_as_user_target"; }

delete_links() {
  _delete_links_dir=$1 && shift
  "$@" find "$_delete_links_dir" -type l 2>/dev/null | while IFS= read -r _entry; do # lists links
    # matches entries to ignore, usually system directories
    case $_entry in */.local/share/containers/* | */lost+found/* | /usr/*-linux-*/*) continue ;; esac
    case $_entry in /boot/* | /dev/* | /efi/* | /media/* | /mnt/*) continue ;; esac
    case $_entry in /opt/* | /proc/* | /run/* | /sys/* | /tmp/* | /var/*) continue ;; esac
    case $_entry in /etc/pam.d/* | /etc/runlevels/* | /etc/ssl/*) continue ;; esac
    case $_entry in /usr/include/* | /usr/lib/* | /usr/lib64/*) continue ;; esac
    case $_entry in /usr/libexec/* | /usr/local/* | /usr/share/* | /usr/src/*) continue ;; esac
    # resolves link, deletes it and deletes all parent directories if empty
    "$@" find "$_entry" -printf '%l\n' 2>/dev/null | while IFS= read -r _path; do
      case $_path in */dotfiles/*) "$@" rm "$_entry" && echo "'$_entry' X" &&
        "$@" rmdir -p "$(dirname "$_entry")" 2>/dev/null ;;
      esac
    done
  done
}
delete_links_as_root() { delete_links / run_as_root; }
delete_links_as_user() { _delete_links_as_user_user=$1 && _delete_links_as_user_dir=$2 &&
  delete_links "$_delete_links_dir" run_as_user "$_delete_links_as_user_user"; }

setup_doas() { _setup_doas_conf=$1 &&
  { ! command -v doas >/dev/null && run_as_root emerge --ask=n -n app-admin/doas || true; } &&
  run_as_root cp -f "$_setup_doas_conf" /etc/doas.conf &&
  run_as_root chown root:root /etc/doas.conf &&
  run_as_root chmod u=rw /etc/doas.conf &&
  run_as_root passwd -dl root >/dev/null; }

get_first_wheel_user() { is_root && grep ^wheel: /etc/group | cut -d, -f2 | grep -v root || whoami; }
get_home() { _get_home_user=$1 &&
  { is_linux && echo "/home/$_get_home_user"; } ||
  { is_macos && echo "/Users/$_get_home_user"; }; }

get_parameter() {
  _get_parameter_flag=$1 && shift
  while [ $# -ge 1 ]; do
    _get_parameter_param=$1 && shift
    [ "$_get_parameter_flag" = "$_get_parameter_param" ] && {
      _get_parameter_val='' && [ $# -ge 1 ] && _get_parameter_val=$1
      # prints out if not starting by -
      [ -n "$_get_parameter_val" ] && expr "x$_get_parameter_val" : 'x[^-]' >/dev/null &&
        echo "$_get_parameter_val" || true
    } && return 0
  done && return 1
}

dots_bootstrap() {
  _dots_bootstrap_user=$1
  _dots_bootstrap_home=$(get_home "$_dots_bootstrap_user") || return 1
  [ -d "$_dots_bootstrap_home/workspace/personal/dotfiles/.git" ] && return 0
  run_as_user "$_dots_bootstrap_user" mkdir -p "$_dots_bootstrap_home/workspace/personal"
  run_as_user "$_dots_bootstrap_user" rm -fr "$_dots_bootstrap_home/workspace/personal/dotfiles"
  run_as_user "$_dots_bootstrap_user" git clone https://github.com/pedro-pereira-dev/dotfiles.git "$_dots_bootstrap_home/workspace/personal/dotfiles"
}
dots_update() {
  _dots_update_user=$1
  _dots_update_home=$(get_home "$_dots_update_user") || return 1
  run_as_user "$_dots_update_user" git -C "$_dots_update_home/workspace/personal/dotfiles" fetch origin || return 1
  run_as_user "$_dots_update_user" git -C "$_dots_update_home/workspace/personal/dotfiles" reset --hard origin/main || return 1
  run_as_user "$_dots_update_user" git -C "$_dots_update_home/workspace/personal/dotfiles" clean -dfqx
}
dots_sync() {
  _dots_sync_hostname=$1 && shift && _dots_sync_user=$1 && shift
  _dots_sync_home=$(get_home "$_dots_sync_user") || return 1
  . "$_dots_sync_home/workspace/personal/dotfiles/hosts/$_dots_sync_hostname/$_dots_sync_hostname.sh" || return 1
  configure "$@"
}

_hostname=$(get_parameter --hostname "$@") && [ -n "$_hostname" ] || _hostname=$(hostname) ||
  { echo '[E] missing required argument --hostname' && exit 1; }
_user=$(get_parameter --user "$@") && [ -n "$_user" ] || _user=$(get_first_wheel_user) ||
  { echo '[E] missing required argument --user' && exit 1; }
[ "$#" -ge 1 ] && _CMD=$1 && shift && case $_CMD in

update) dots_bootstrap "$_user" && dots_update "$_user" || exit 1 ;;
sync) dots_bootstrap "$_user" && dots_sync "$_hostname" "$_user" "$@" || exit 1 ;;

*) exit 1 ;; esac && exit 0
