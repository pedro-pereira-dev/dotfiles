#!/sbin/openrc-run

_USER="${RC_SVCNAME#*.}"

depend() {
  need net net-online "user.$_USER"
  after *
}

start() {
  ebegin "Starting user $_USER podman-compose"

  su "$_USER" -c "\
    podman-compose -f ~/.podman/compose.yaml \
    up -d --force-recreate --pull-always --remove-orphans"

  eend $?
}
