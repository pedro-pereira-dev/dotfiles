#!/bin/bash

function has_tmux_session() { tmux has-session -t="$1" >/dev/null 2>&1; }
function is_tmux_running() { [[ -n $(pgrep tmux) ]] && return 0 || return 1; }
function is_tmux_session() { [[ -n ${TMUX} ]] && return 0 || return 1; }
function find_target() {
  find ~/workspace -type d \
    -exec /bin/test -d '{}/.git' -a '{}' != '.' \; -print -prune \
    -o -print
}

TARGET=$(zoxide query "${@:1}" 2>/dev/null)
[[ -z ${*:1} ]] && TARGET=$(find_target | fzf)
[[ -n ${*:1} && -z ${TARGET} ]] && TARGET=$(find_target | fzf --query "${*:1}")
[[ -z ${TARGET} ]] && exit 0

REALPATH_TARGET=$(realpath "${TARGET}")
SESSION_NAME=$(basename "${REALPATH_TARGET}")

if is_tmux_session; then
  if ! has_tmux_session "${SESSION_NAME}"; then
    # creates new detached session
    tmux new-session -d -s "${SESSION_NAME}" -c "${REALPATH_TARGET}"
  fi
  # switches to session
  tmux switch-client -t "${SESSION_NAME}"
else
  if has_tmux_session "${SESSION_NAME}"; then
    # attaches to session and detaches all other clients from all sessions
    tmux attach -t "${SESSION_NAME}" \; detach-client -a
  else
    # creates and attaches new session, and detaches all other clients from all sessions
    tmux new-session -s "${SESSION_NAME}" -c "${REALPATH_TARGET}" \; detach-client -a
  fi
fi
