#!/sbin/openrc-run

user=${RC_SVCNAME#*.}
config_dir=${config_dir:-'~/.podman/compose.yaml'}

depend() { need net net-online "user.$user"; }

start() {
  ebegin "Starting $user podman-compose containers"
  su "$user" -c "podman-compose -f $config_dir up -d --force-recreate --pull-always --remove-orphans"
  eend $?
}
