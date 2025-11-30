#!/sbin/openrc-run

depend() {
  need net-online "user-runtime.${RC_SVCNAME#*.}"
  after sshd
}

start() {
  su "${RC_SVCNAME#*.}" -c "podman-compose -f /home/${RC_SVCNAME#*.}/.podman/compose.yaml pull"
  su "${RC_SVCNAME#*.}" -c "podman-compose -f /home/${RC_SVCNAME#*.}/.podman/compose.yaml up -d --force-recreate --remove-orphans"
  eend $?
}
