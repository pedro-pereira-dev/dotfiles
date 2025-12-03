#!/sbin/openrc-run

socket=${socket:-/tmp/podman.sock}
timeout=${timeout:-30}
user=${RC_SVCNAME#*.}

depend() { need "user.$user"; }

start() {
  ebegin "Starting $user podman socket"
  su "$user" -c "podman system service -t 0 unix://$socket &"
  count=0 && while [ $count -lt "$timeout" ]; do
    chmod g+rw "$socket" 2>/dev/null && eend 0 && return 0
    sleep 1 && count=$((count + 1))
  done && eend 1 && return 1
}
