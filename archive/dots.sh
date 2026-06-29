#!/bin/sh
# shellcheck disable=SC2015,SC2329 source=/dev/null
set -eou pipefail

is_linux() { test "$(uname)" = Linux; }
is_macos() { test "$(uname)" = Darwin; }

is_root() { is_user root; }
is_user() { _is_user_user=$1 && test "$(id -u)" -eq "$(id -u "$_is_user_user")"; }

run_as_root() {
  is_root && "$@"
  is_root && return $?
  command -v doas >/dev/null && doas "$@"
  command -v doas >/dev/null && return $?
  command -v sudo >/dev/null && sudo "$@"
  command -v sudo >/dev/null && return $?
}
run_as_user() {
  _run_as_user_user=$1 && shift
  is_user "$_run_as_user_user" && "$@"
  is_user "$_run_as_user_user" && return $?
  run_as_root su "$_run_as_user_user" -c "$(printf '%s ' "$@")"
}

link_as_root() {
  _link_as_root_source=$1 && _link_as_root_target=$2
  run_as_root rm -fr "$_link_as_root_target"
  run_as_root mkdir -p "$(dirname "$_link_as_root_target")"
  run_as_root ln -fsv "$_link_as_root_source" "$_link_as_root_target"
}
link_as_user() {
  _link_as_user_user=$1 && _link_as_user_source=$2 && _link_as_user_target=$3
  run_as_user "$_link_as_user_user" rm -fr "$_link_as_user_target"
  run_as_user "$_link_as_user_user" mkdir -p "$(dirname "$_link_as_user_target")"
  run_as_user "$_link_as_user_user" ln -fsv "$_link_as_user_source" "$_link_as_user_target"
}

link_root_host() { link_as_root "$_DOTS/hosts/$_HOSTNAME/$1" "$2"; }
link_root_shared() { link_as_root "$_DOTS/files/$1" "$2"; }
link_user_host() { link_as_user "$_user" "$_DOTS/hosts/$_HOSTNAME/$1" "$_home/$2"; }
link_user_shared() { link_as_user "$_user" "$_DOTS/files/$1" "$_home/$2"; }

delete_links() {
  _delete_links_dir=$1 && shift
  "$@" find "$_delete_links_dir" -type l 2>/dev/null |
    # lists all system links
    while IFS= read -r _link; do
      # ignored entries
      case $_link in */.local/share/containers/* | */lost+found/* | /usr/*-linux-*/*) continue ;; esac
      case $_link in /boot/* | /dev/* | /efi/* | /media/* | /mnt/*) continue ;; esac
      case $_link in /opt/* | /proc/* | /run/* | /sys/* | /tmp/* | /var/*) continue ;; esac
      case $_link in /etc/pam.d/* | /etc/runlevels/* | /etc/ssl/*) continue ;; esac
      case $_link in /usr/include/* | /usr/lib/* | /usr/lib64/*) continue ;; esac
      case $_link in /usr/libexec/* | /usr/local/* | /usr/share/* | /usr/src/*) continue ;; esac
      # cheks if link is a dotfiles resources and deletes it if it is
      "$@" find "$_link" -printf '%l\n' 2>/dev/null |
        while IFS= read -r _link_path; do
          case $_link_path in */$_dots_path/*)
            "$@" rm "$_link"
            echo "'$_link' X"
            "$@" rmdir -p "$(dirname "$_link")" 2>/dev/null
            ;;
          esac
        done
    done
}

delete_links_as_root() { delete_links / run_as_root; }
delete_links_as_user() {
  _delete_links_as_user_user=$1 && _delete_links_as_user_dir=$2
  delete_links "$_delete_links_dir" run_as_user "$_delete_links_as_user_user"
}

get_first_wheel_user() {
  is_root && grep ^wheel: /etc/group | cut -d, -f2 | grep -v root
  is_root && return $?
  ! is_root && whoami
  ! is_root && return $?
}
get_home() {
  _get_home_user=$1
  is_linux && echo "/home/$_get_home_user"
  is_linux && return $?
  is_macos && echo "/Users/$_get_home_user"
  is_macos && return $?
}
get_parameter() {
  _get_parameter_flag=$1 && shift
  while [ $# -ge 1 ]; do
    _get_parameter_param=$1 && shift
    [ "$_get_parameter_flag" != "$_get_parameter_param" ] && continue
    _get_parameter_val='' && [ $# -ge 1 ] && _get_parameter_val=$1
    [ -n "$_get_parameter_val" ] &&
      expr "x$_get_parameter_val" : 'x[^-]' >/dev/null &&
      echo "$_get_parameter_val"
    return 0
  done
  return 1
}
get_uuid() {
  _get_uuid_part=$1
  blkid -o export "$_get_uuid_part" | grep ^UUID | cut -d= -f2
}

setup_doas() {
  _setup_doas_conf=$1
  ! command -v doas >/dev/null &&
    { run_as_root emerge --ask=n -n app-admin/doas || return 1; }
  ! doas -C "$_setup_doas_conf" 2>/dev/null && return 1
  run_as_root cp -f "$_setup_doas_conf" /etc/doas.conf
  run_as_root chown root:root /etc/doas.conf
  run_as_root chmod u=rw /etc/doas.conf
  run_as_root passwd -dl root >/dev/null
}
setup_fcron() {
  _setup_fcron_conf=$1
  ! command -v fcrontab >/dev/null && return 1
  run_as_root /usr/bin/fcrontab "$_setup_fcron_conf"
}
setup_openrc() {
  _setup_openrc_conf=$1
  [ ! -f "$_setup_openrc_conf" ] && return 1
  _declared=$(mktemp)
  sed -E \
    -e '/^[[:space:]]*([#]|$)/d' \
    -e 's/([[:space:]])+#.*$//' \
    "$_setup_openrc_conf" | sort -u >"$_declared"
  _enabled=$(mktemp)
  rc-update show default | awk '{print $1}' | sort -u >"$_enabled"
  _add=$(mktemp)
  comm -23 "$_declared" "$_enabled" >"$_add"
  _delete=$(mktemp)
  comm -23 "$_enabled" "$_declared" >"$_delete"
  [ -s "$_add" ] &&
    cat "$_add" | run_as_root xargs -I {} rc-update add {} default
  [ -s "$_delete" ] &&
    cat "$_delete" | run_as_root xargs -I {} rc-update del {} default
  rm -f "$_add" "$_declared" "$_delete" "$_enabled"
}

_HOSTNAME=$(get_parameter --hostname "$@") && [ -n "$_HOSTNAME" ] ||
  _HOSTNAME=$(hostname) ||
  { echo '[E] missing required argument --hostname' && exit 1; }
_user=$(get_parameter --user "$@") && [ -n "$_user" ] ||
  _user=$(get_first_wheel_user) ||
  { echo '[E] missing required argument --user' && exit 1; }

_home=$(get_home "$_user") || exit 1
_url=$(get_parameter --url "$@") && [ -n "$_url" ] ||
  _url=https://github.com/pedro-pereira-dev/dotfiles.git

_dots_path=workspace/personal/dotfiles
_DOTS=$_home/$_dots_path

[ ! -d "$_DOTS/.git" ] && {
  run_as_user "$_user" mkdir -p "$(dirname "$_DOTS")"
  run_as_user "$_user" rm -fr "$_DOTS"
  run_as_user "$_user" git clone "$_url" "$_DOTS" || exit 1
}

dots_update() {
  run_as_user "$_user" git -C "$_DOTS" fetch origin || return 1
  _branch=$(get_parameter --branch "$@") && [ -n "$_branch" ] &&
    { run_as_user "$_user" git -C "$_DOTS" checkout -f "$_branch" || return 1; }
  run_as_user "$_user" git -C "$_DOTS" reset --hard "@{u}" || return 1
  run_as_user "$_user" git -C "$_DOTS" clean -dfqx || return 1
}

dots_sync() {
  . "$_DOTS/hosts/$_HOSTNAME/$_HOSTNAME.sh" || return 1
  sync "$@" || return 1
}

[ "$#" -ge 1 ] && _cmd=$1 && shift && case $_cmd in
update) dots_update "$@" || exit 1 ;;
sync) dots_sync "$@" || exit 1 ;;
*) exit 1 ;;
esac
