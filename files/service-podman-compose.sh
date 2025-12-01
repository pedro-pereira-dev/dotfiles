#!/sbin/openrc-run

depend() {
  need net net-online "user.${RC_SVCNAME#*.}"
  after *
}

start() {
  ebegin "Starting user ${RC_SVCNAME#*.} podman-compose"

  su "${RC_SVCNAME#*.}" -c "\
    podman-compose -f ~/.podman/compose.yaml \
    up -d --force-recreate --pull-always --remove-orphans"

  eend $?
}
