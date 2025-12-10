#!/sbin/openrc-run

user=${RC_SVCNAME#*.}
config=${config:-'~/.podman/compose.yaml'}

depend() {
  need net net-online "user.$user"
  use "podman-socket.$user"
  after *
}

start() {
  ebegin "Starting podman-compose containers for $user"
  su "$user" -c "podman-compose -f $config up -d --force-recreate --remove-orphans"
  eend $?
}

stop() {
  ebegin "Stopping podman-compose containers for $user"
  su "$user" -c "podman-compose -f $config down --remove-orphans"
  eend $?
}
