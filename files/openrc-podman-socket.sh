#!/sbin/openrc-run

socket=${socket:-'unix:///tmp/podman.sock'}
timeout=${timeout:-30}
user=${RC_SVCNAME#*.}

depend() {
  need "user.$user"
  after *
}

start() {
  ebegin "Starting podman socket for $user"
  su "$user" -c "podman system service -t 0 $socket &"
  eend 0 && return 0
}
