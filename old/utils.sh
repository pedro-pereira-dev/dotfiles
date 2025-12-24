#!/bin/sh
# shellcheck source=/dev/null

_IS_DOTS_UTILS_LOADED='true'

is_aarch64() { test "$(uname -m)" = 'aarch64'; }
is_amd64() { test "$(uname -m)" = 'x86_64'; }

is_bios() { ! is_uefi; }
is_uefi() { test -d '/sys/firmware/efi'; }

is_linux() { test "$(uname)" = 'Linux'; }
is_macos() { test "$(uname)" = 'Darwin'; }

is_gentoo() { test "$(cat /etc/*-release | grep DISTRIB_ID | cut -d'"' -f2)" = 'Gentoo'; }

is_non_root() { ! is_root; }
is_root() { test "$(id -u)" -eq 0; }

check_command() { which "$1" >/dev/null 2>&1; }

calculate_next_aligned_sector() {
  _PREVIOUS_SECTOR='' && [ "$#" -ge 1 ] && _PREVIOUS_SECTOR="$1" && shift
  _B_SIZE=$((_PREVIOUS_SECTOR / 2048))
  _NEXT_B=$((_B_SIZE + 1))
  _NEXT_SECTOR=$((_NEXT_B * 2048))
  echo "$_NEXT_SECTOR"
}

calculate_size_in_sectors() {
  _GB_SIZE='' && [ "$#" -ge 1 ] && _GB_SIZE="$1" && shift
  _B_SIZE=$((_GB_SIZE * 1024 * 1024 * 1024))
  _N_SECTORS=$((_B_SIZE / 512))
  echo "$_N_SECTORS"
}

install_homebrew() {
  _TMP_FILE=$(mktemp)
  curl -Lfs 'https://raw.githubusercontent.com/homebrew/install/refs/heads/main/install.sh' >"$_TMP_FILE"
  NONINTERACTIVE=1 sh "$_TMP_FILE"
  rm "$_TMP_FILE"
}

install_git() {
  _USER='' && [ "$#" -ge 1 ] && _USER="$1"
  check_command brew && run_as_user "$_USER" brew install git
  check_command emerge && run_as_root emerge --ask=n --noreplace dev-vcs/git
}

get_option() {
  _OPT='' && [ "$#" -ge 1 ] && _OPT="$1" && shift
  while [ "$#" -gt 0 ]; do
    _ARG="$1" && shift
    if [ "$_OPT" = "$_ARG" ]; then
      [ "$#" -gt 0 ] && expr "x$1" : 'x[^-]' >/dev/null && echo "$1"
      return 0
    fi
  done
  return 1
}

get_home() {
  _USER="$(get_user "$@")" || return 1
  [ "$(uname)" = 'Darwin' ] && echo "/Users/$_USER" && return 0
  [ "$(uname)" = 'Linux' ] && echo "/home/$_USER" && return 0
  return 1
}

get_hostname() {
  _HOSTNAME="$(get_option '--hostname' "$@")" || true
  [ -n "$_HOSTNAME" ] && echo "$_HOSTNAME" && return 0
  is_linux && cat /etc/hostname 2>/dev/null && return 0
  is_macos && hostname && return 0
  return 1
}

get_user() {
  _USER="$(get_option '--user' "$@")" || true
  [ -n "$_USER" ] && echo "$_USER" && return 0
  is_non_root && whoami && return 0
  is_root && get_wheel_user && return 0
  return 1
}

get_wheel_user() {
  grep '^wheel:' /etc/group | cut -d',' -f2 | grep -v 'root'
}

remove_broken_links() {
  find "${1:-/}" -type l -exec sh -c \
    'test ! -e "$1" && rm -f "$1" >/dev/null 2>&1 && echo "[I] removing broken link: $1"' \
    _ {} \;
}

run_as_root() {
  if is_root; then
    "$@"
  elif check_command doas; then
    doas sh -c ". $_TMP_UTILS_FILE && $*"
  elif check_command sudo; then
    sudo sh -c ". $_TMP_UTILS_FILE && $*"
  fi
}

run_as_user() {
  _USER='' && [ "$#" -ge 1 ] && _USER="$1" && shift
  if is_non_root; then
    "$@"
  elif is_root; then
    su "$_USER" -c ". $_TMP_UTILS_FILE && $*"
  fi
}

source_file() {
  _FILE_TO_SOURCE='' && [ "$#" -ge 1 ] && _FILE_TO_SOURCE="$1"
  [ -z "$_FILE_TO_SOURCE" ] && return 1
  if [ -f "$_SCRIPT_DIR/$_FILE_TO_SOURCE" ]; then
    . "$_SCRIPT_DIR/$_FILE_TO_SOURCE" && return 0
  elif curl -ILfs "$_DOTS_RAW_URL/$_FILE_TO_SOURCE" >/dev/null; then
    _TMP_FILE=$(mktemp)
    curl -Lfs "$_DOTS_RAW_URL/$_FILE_TO_SOURCE" >"$_TMP_FILE"
    . "$_TMP_FILE" && rm "$_TMP_FILE" && return 0
  fi
  return 1
}

stow() {
  _SOURCE="$1"
  _TARGET="$2" && [ "$2" = '/' ] && _TARGET=''
  is_source_a_dir() { test -d "$_SOURCE"; }
  is_target_a_dir() { expr "$_TARGET" : '.*/$' >/dev/null; }
  is_source_a_dir && is_target_a_dir && (
    for _SOURCE_ENTRY in "$_SOURCE"* "$_SOURCE".[!.]*; do
      [ ! -e "$_SOURCE_ENTRY" ] && continue
      _SOURCE_PATH="${_SOURCE_ENTRY#"$_SOURCE"}"
      mkdir -p "$(dirname "$_TARGET$_SOURCE_PATH")"
      rm -fr "$_TARGET$_SOURCE_PATH"
      ln -fs "$_SOURCE_ENTRY" "$_TARGET$_SOURCE_PATH"
      echo "[I] linking entry to path: $_SOURCE_ENTRY $_TARGET$_SOURCE_PATH"
    done
  ) && return 0
  is_source_a_dir && ! is_target_a_dir && (
    mkdir -p "$(dirname "$_TARGET")"
    rm -fr "$_TARGET"
    ln -fs "$_SOURCE" "$_TARGET"
    echo "[I] linking directory to directory: $_SOURCE $_TARGET"
  ) && return 0
  ! is_source_a_dir && is_target_a_dir && (
    mkdir -p "$_TARGET"
    rm -fr "$_TARGET$(basename "$_SOURCE")"
    ln -fs "$_SOURCE" "$_TARGET$(basename "$_SOURCE")"
    echo "[I] linking file to directory: $_SOURCE $_TARGET$(basename "$_SOURCE")"
  ) && return 0
  ! is_source_a_dir && ! is_target_a_dir && (
    mkdir -p "$(dirname "$_TARGET")"
    rm -fr "$_TARGET"
    ln -fs "$_SOURCE" "$_TARGET"
    echo "[I] linking file to file: $_SOURCE $_TARGET"
  ) && return 0
  return 1
}
