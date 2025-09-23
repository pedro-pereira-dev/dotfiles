#!/bin/bash
set -eou pipefail
function _main() {
  _SCRIPT_DIR="$_HOME/$_DOTS_DIR/$(dirname "$1")" && shift
  _CMD='' && [ "$#" -ge 1 ] && _CMD="$1"
  case $_CMD in

  configure)
    # _REMOTE_FILE_URL='https://raw.githubusercontent.com/pedro-pereira-dev/dotfiles/refs/heads/main/dots-utils'
    # which 'dots-utils' >/dev/null && source "$(which 'dots-utils')" ||
    #   curl -ILfs "$_REMOTE_FILE_URL" >/dev/null && source /dev/stdin <<<"$(curl -Lfs "$_REMOTE_FILE_URL")"
    [[ ":$PATH:" != *":$HOME/.local/bin:"* ]] && export PATH="$HOME/.local/bin:$PATH"
    [[ ":$PATH:" != *':/usr/bin:'* ]] && export PATH="/usr/bin:$PATH"
    is_macos && [[ ":$PATH:" != *':/opt/homebrew/bin:'* ]] && export PATH="/opt/homebrew/bin:$PATH"
    return 0
    ;;

  setup)
    run_as_user "$_USER" stow "$_HOME/$_DOTS_DIR/dots" "$_HOME/.local/bin/dots"
    run_as_user "$_USER" stow "$_HOME/$_DOTS_DIR/dots-utils" "$_HOME/.local/bin/dots-utils"
    ;;

  *) return 1 ;;
  esac
}
_main "$@"
