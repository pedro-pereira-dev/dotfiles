#!/sbin/openrc-run

_USER="${RC_SVCNAME#*.}"
_USER_DIR=/run/user/$(id -u "${_USER}")

supervisor=supervise-daemon

command=/usr/libexec/rc/bin/openrc-user
command_args=${_USER}

notify=fd:3
respawn_max=3
respawn_period=5

start_pre() {
  ebegin "Starting user ${RC_SVCNAME#*.} runtime direcory"

  [ "${_USER}" = "${RC_SVCNAME}" ] &&
    eend 1 && return 1

  [ -z "${XDG_RUNTIME_DIR}" ] &&
    export XDG_RUNTIME_DIR=${_USER_DIR}
  [ ! -d "${XDG_RUNTIME_DIR}" ] &&
    mkdir -p "${XDG_RUNTIME_DIR}" &&
    chmod 0700 "${XDG_RUNTIME_DIR}" &&
    chown "${RC_SVCNAME#*.}:${RC_SVCNAME#*.}" "${XDG_RUNTIME_DIR}"

  eend 0 && return 0
}
