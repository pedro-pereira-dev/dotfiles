#!/sbin/openrc-run

user=${RC_SVCNAME#*.}
runtime_dir=/run/user/$(id -u "$user")

command=/usr/libexec/rc/bin/openrc-user
command_args=$user

notify=fd:3
respawn_max=3
respawn_period=5

supervisor=supervise-daemon

start_pre() {
  ebegin "Starting $user runtime direcory"
  [ "$user" = "$RC_SVCNAME" ] &&
    eend 1 && return 1
  [ -z "$XDG_RUNTIME_DIR" ] &&
    export XDG_RUNTIME_DIR=$runtime_dir
  [ ! -d "$XDG_RUNTIME_DIR" ] &&
    mkdir -p "$XDG_RUNTIME_DIR" &&
    chmod 0700 "$XDG_RUNTIME_DIR" &&
    chown "$user:$user" "$XDG_RUNTIME_DIR"
  eend 0 && return 0
}
