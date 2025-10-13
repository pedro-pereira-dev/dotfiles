#!/bin/sh
# shellcheck source=/dev/null

_IS_DOTS_UTILS_LOADED='true'

is_aarch64() { test "$(uname -m)" = 'aarch64'; }
is_amd64() { test "$(uname -m)" = 'x86_64'; }

is_bios() { ! test -d '/sys/firmware/efi'; }
is_uefi() { test -d '/sys/firmware/efi'; }

is_linux() { test "$(uname)" = 'Linux'; }
is_macos() { test "$(uname)" = 'Darwin'; }

is_non_root() { ! is_root; }
is_root() { test "$(id -u)" -eq 0; }

check_command() { which "$1" >/dev/null 2>&1; }

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

run_as_root() {
  if is_root; then
    "$@"
  elif check_command doas; then
    doas "$@"
  elif check_command sudo; then
    sudo "$@"
  else
    return 1
  fi
}

run_as_user() {
  _USER='' && [ "$#" -ge 1 ] && _USER="$1" && shift
  if is_non_root; then "$@" && echo; fi
  if is_root; then su "$_USER" -c "$@"; fi
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
    _TARGET_DIR="${_TARGET%/}"
    mkdir -p "$(dirname "$_TARGET_DIR")"
    rm -fr "$_TARGET_DIR"
    ln -fs "$_SOURCE" "$_TARGET_DIR"
    echo "[I] linking directory to directory: $_SOURCE $_TARGET_DIR"
    return 0
  )
  ! is_source_a_dir && ! is_target_a_dir && (
    mkdir -p "$(dirname "$_TARGET")"
    rm -fr "$_TARGET"
    ln -fs "$1" "$_TARGET"
    echo "[I] linking file to file: $1 $_TARGET"
    return 0
  )
  return 1
}

# # ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- -----
# # finds and deletes empty directories and broken symlinks
# # arguments:
# #   $1 - the directory to clear
# # returns:
# #   0 (success) if deletion was successful
# #   1 (failure) if deletion was unsuccessful
# function clean_directories_and_links() {
#   _COUNTER=3
#   _OLD_RESULT='undefined'
#   while true; do
#     _RESULT="$(find "$1" \( \
#       -name 'Applications' -o \
#       -name 'Library' -o \
#       -name 'lost+found' -o \
#       -path '/System' -o \
#       -path '/Volumes' -o \
#       -path '/boot' -o \
#       -path '/dev' -o \
#       -path '/efi' -o \
#       -path '/mnt' -o \
#       -path '/private' -o \
#       -path '/proc' -o \
#       -path '/run' -o \
#       -path '/sys' -o \
#       -path '/tmp' \
#       \) -prune \
#       -o \( -type d -empty -o -type l -not -exec test -e {} \; \) \
#       -print)"
#     [ -n "$_RESULT" ] &&
#       echo "$_RESULT" | sed '/^\s*$/d' | while read -r _ENTRY; do
#         ([ -d "$_ENTRY" ] && rmdir -p "$_ENTRY" 2>/dev/null || rm -fr "$_ENTRY" 2>/dev/null) &&
#         echo "[I] removing: $_ENTRY"
#       done
#     [ -z "$_RESULT" ] && return 0
#     [ "$_OLD_RESULT" == "$_RESULT" ] && _COUNTER=$((_COUNTER - 1))
#     [ "$_COUNTER" -lt 0 ] && return 1
#     _OLD_RESULT="$_RESULT"
#   done
# }
# export -f clean_directories_and_links
#
# # ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- -----
# # runs a script from the local filesystem or directly from github
# # arguments:
# #   $1 - the relative path to the script to execute from the base dotfiles directory
# #   $@ - all subsequent arguments, which form the command and its arguments
# #        to be executed (e.g., 'install', 'sync')
# # returns:
# #   the exit status of the executed command
# #   1 (failure) if any failure occurs
# function run_script() {
#   _LOCAL_SCRIPT="$(dirname "$(readlink -f "$0")")/$1"
#   _REMOTE_SCRIPT="$_DOTS_RAW_URL/$1"
#   if [ -f "$_LOCAL_SCRIPT" ]; then
#     bash "$_LOCAL_SCRIPT" "${@:2}"
#   elif curl -ILfs "$_REMOTE_SCRIPT" >/dev/null; then
#     curl -Lfs "$_REMOTE_SCRIPT" | bash -s -- "${@:2}"
#   else
#     return 1
#   fi
# }
# export -f run_script
#
# # ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- -----
# # links a directory or file into a target directory or file, overwriting the target if it exists
# # arguments:
# #   $1 - the absolute path of the source directory or file
# #   $2 - the absolute path of the target directory or file
# # returns:
# #   0 (success) if successful linking of all files
# #   1 (failure) if unsuccessful or partial linking
# function stow() {
#   function list_files() { find "$1" \( -type f -o -type l \) -print0; }
#   function list_dirs() { find "$1" -mindepth 1 -type d -print0; }
#   _DST="$2" && [ "$2" == '/' ] && _DST=''
#
#   if [ -d "$1" ]; then
#     if [[ "$_DST" == */ ]]; then
#       mkdir -p "$(dirname "${_DST%/}")"
#       rm -fr "${_DST%/}"
#       ln -fs "$1" "${_DST%/}"
#       echo "[I] linking directory to directory: $1 ${_DST%/}"
#     else
#       while IFS= read -r -d '' _SRC_SUBDIR; do
#         [ -f "$_DST${_SRC_SUBDIR/$1/}" ] && rm -fr "$_DST${_SRC_SUBDIR/$1/}"
#         mkdir -p "$_DST${_SRC_SUBDIR/$1/}"
#       done < <(list_dirs "$1")
#       while IFS= read -r -d '' _SRC_FILE; do
#         [ -f "$(dirname "$_DST${_SRC_FILE/$1/}")" ] && rm -fr "$(dirname "$_DST${_SRC_FILE/$1/}")"
#         mkdir -p "$(dirname "$_DST${_SRC_FILE/$1/}")"
#         rm -fr "$_DST${_SRC_FILE/$1/}"
#         ln -fs "$_SRC_FILE" "$_DST${_SRC_FILE/$1/}"
#         echo "[I] linking directory to file: $_SRC_FILE $_DST${_SRC_FILE/$1/}"
#       done < <(list_files "$1")
#     fi
#   elif [ -f "$1" ]; then
#     if [[ "$_DST" == */ ]]; then
#       echo "[E] dots-utils#stow : cannot link file to directory: $1 -> ${_DST%/}" && return 1
#     else
#       mkdir -p "$(dirname "$_DST")"
#       rm -fr "$_DST"
#       ln -fs "$1" "$_DST"
#       echo "[I] linking file to file: $1 $_DST"
#     fi
#
#   else
#     return 1
#   fi
#   return 0
# }
# export -f stow
#
# # ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- -----
# # links a directory containing the root and home to the system
# # arguments:
# #   $1 - the directory to link
# # returns:
# #   0 (success) if successful linking of all files
# #   1 (failure) if unsuccessful or partial linking
# function stow_directory() {
#   _HOME="$(get_home "$@")" || return 1
#   _USER="$(get_user "$@")" || return 1
#   _LOCAL_DIR="$_HOME/$_DOTS_DIR/hosts/$1.d"
#   [ -d "$_LOCAL_DIR/root" ] && (run_as_root stow "$_LOCAL_DIR/root" '/' || return 1)
#   [ -d "$_LOCAL_DIR/home" ] && (run_as_user "$_USER" stow "$_LOCAL_DIR/home" "$_HOME" || return 1)
#   return 0
# }
# export -f stow_directory
#
