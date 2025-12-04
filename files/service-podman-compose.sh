#!/sbin/openrc-run

user=${RC_SVCNAME#*.}
config=${config:-'~/.podman/compose.yaml'}

depend() { need net net-online "user.$user"; }

start() {
  ebegin "Starting podman-compose containers for $user"
  su "$user" -c "podman-compose -f $config up -d \
    --force-recreate --pull-always --remove-orphans"
  eend $?
}
