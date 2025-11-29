#!/sbin/openrc-run

command_user="${RC_SVCNAME#*.}"
command="/usr/bin/podman-compose"
command_args="-f /home/${RC_SVCNAME#*.}/.podman/compose.yaml up -d --force-recreate --remove-orphans"

depend() {
  need dbus elogind net net-online user.${RC_SVCNAME#*.}
}
