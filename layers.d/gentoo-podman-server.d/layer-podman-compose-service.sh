#!/sbin/openrc-run
# https://github.com/OpenRC/openrc/blob/master/service-script-guide.md
# https://wiki.gentoo.org/wiki/Handbook:X86/Working/Initscripts#Writing_initscripts

command="/usr/bin/podman-compose"
command_args="-f ~/.podman/compose.yaml"
command_user="chuck"

depend() {
  need net
}

start() {
  su - $command_user -c "$command $command_args up -d"
  eend $?
}

stop() {
  su - $command_user -c "$command $command_args down"
  eend $?
}
