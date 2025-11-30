#!/sbin/openrc-run

_TEST_DOMAIN=one.one.one.one
_TIMEOUT=30 # seconds

depend() {
  need net-online "user-runtime.${RC_SVCNAME#*.}"
  after sshd
}

start_pre() {
  ebegin 'Waiting for DNS'
  for _ITER in $(seq 1 "${_TIMEOUT}"); do
    getent hosts ${_TEST_DOMAIN} >/dev/null 2>&1 &&
      eend 0 'DNS resolution working' && return 0
    sleep 1
  done
  eend 1 'DNS resolution not working'
  return 1
}

start() {
  su "${RC_SVCNAME#*.}" -c "podman-compose -f /home/${RC_SVCNAME#*.}/.podman/compose.yaml pull"
  su "${RC_SVCNAME#*.}" -c "podman-compose -f /home/${RC_SVCNAME#*.}/.podman/compose.yaml up -d --force-recreate --remove-orphans"
  eend $?
}
