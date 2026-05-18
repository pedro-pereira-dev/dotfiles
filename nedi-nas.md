# `nedi-nas`

## Details

- Site: Personal
- OS: Debian 13
- IPv4: `192.168.0.42`

Ports opened:

```
```

## Initial system setup

```bash
# creates debian lxc
bash -c "$(curl -fsSL https://raw.githubusercontent.com/community-scripts/ProxmoxVE/main/ct/debian.sh)"
# privileged - mounting, fuse - mergerfs
pct stop 1042

# add additinal 128gb mountpoint to /local
# mounts additional disks
cat << EOF >> /etc/pve/lxc/1042.conf
mp0: data:vm-1042-disk-1,mp=/local,size=128G
dev0: /dev/sdb1
dev1: /dev/sdc1
dev2: /dev/sdd1
lxc.cgroup2.devices.allow: b 8:* rwm
EOF

pct start 1042
pct enter 1042

# sets up ssh server
cat << EOF > /root/.ssh/authorized_keys
ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJbHkOpoucRSqD/zKiyC2xtjw0F/JeUtZlrmMuLy2iWd 11753516+pedro-pereira-dev@users.noreply.github.com
EOF
cat << EOF > /etc/ssh/sshd_config.d/sshd.conf
PasswordAuthentication no
X11Forwarding no
EOF
systemctl restart ssh

# disables ipv6 networking
cat << EOF > /etc/sysctl.d/99-disable-ipv6.conf
net.ipv6.conf.all.disable_ipv6 = 1
net.ipv6.conf.default.disable_ipv6 = 1
net.ipv6.conf.lo.disable_ipv6 = 1
EOF
sysctl --system >/dev/null 2>&1

# sets up apt
rm -f /etc/apt/sources.list /etc/apt/sources.list~ /etc/apt/sources.list.bak
cat << EOF > /etc/apt/sources.list.d/debian.sources
Types: deb
URIs: http://deb.debian.org/debian/
Suites: trixie
Components: main
Signed-By: /usr/share/keyrings/debian-archive-keyring.gpg
$()
Types: deb
URIs: http://deb.debian.org/debian/
Suites: trixie-updates
Components: main
Signed-By: /usr/share/keyrings/debian-archive-keyring.gpg
$()
Types: deb
URIs: http://security.debian.org/debian-security/
Suites: trixie-security
Components: main
Signed-By: /usr/share/keyrings/debian-archive-keyring.gpg
EOF
cat << EOF > /usr/bin/update
#!/bin/sh
apt update
apt full-upgrade -y
apt autoremove -y
EOF
chmod +x /usr/bin/update
update

# installs all required dependencies
apt install -y hdparm mergerfs podman snapraid ufw

# sets up disks
apt install -y mergerfs
mkdir -p /mnt/disks/{fast-02,slow-01,parity-01}
mkdir -p /mnt/storage/{fast,slow}
mkdir -p /data
ln -fs /local /mnt/disks/fast-01
cat << EOF > /etc/fstab
UUID=39a0ece3-e591-4076-b9fa-18623e9441ff   /mnt/disks/fast-02      ext4 defaults 0 0
UUID=3d2a00d4-0650-4a0c-af1c-30e814922cda   /mnt/disks/slow-01      ext4 defaults 0 0
UUID=ce94c2e2-b0e7-40c0-89a0-1846bc567155   /mnt/disks/parity-01    ext4 defaults 0 0
$()
/mnt/disks/fast-*                           /mnt/storage/fast       mergerfs x-systemd.requires-mount-for=/mnt/disks,defaults 0 0
/mnt/disks/slow-*                           /mnt/storage/slow       mergerfs x-systemd.requires-mount-for=/mnt/disks,defaults 0 0
/mnt/disks/fast-*:/mnt/disks/slow-*         /data                   mergerfs x-systemd.requires-mount-for=/mnt/disks,defaults,category.create=ff 0 0
EOF
(crontab -l 2>/dev/null; echo "@reboot mount -a") | crontab -
systemctl daemon-reload
mount -a

# sets up snapraid
apt install -y snapraid
cat << EOF > /etc/snapraid.conf
autosave 64
disk fast-01 /mnt/disks/fast-01
disk fast-02 /mnt/disks/fast-02
disk slow-01 /mnt/disks/slow-01
content /mnt/disks/.snapraid.content
content /mnt/disks/fast-01/.snapraid.content
content /mnt/disks/fast-02/.snapraid.content
content /mnt/disks/slow-01/.snapraid.content
parity  /mnt/disks/parity-01/.snapraid.parity
EOF
snapraid sync

# sets up parity maintenance
cat << 'EOF' > /usr/bin/snapraid-maintenance
#!/bin/bash
set -euo pipefail
snapraid_lockfile=/run/snapraid-maintenance.lock
snapraid_maintenance_lock_fd=9
snapraid_logfile=/var/log/snapraid-maintenance.log
log_message() { echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$snapraid_logfile"; }
! command -v snapraid >/dev/null 2>&1 && log_message 'snapraid not found' && exit 1
! exec {snapraid_maintenance_lock_fd}>"$snapraid_lockfile" && exit 1
! flock -n "$snapraid_maintenance_lock_fd" && log_message 'Another instance is running' && exit 0
log_message 'Starting snapraid maintenance'
snapraid sync 2>&1 | tee -a "$snapraid_logfile" || true
snapraid scrub 2>&1 | tee -a "$snapraid_logfile" || true
snapraid status 2>&1 | tee -a "$snapraid_logfile" || true
log_message 'Completed snapraid maintenance'
EOF
chmod +x /usr/bin/snapraid-maintenance
snapraid-maintenance
(crontab -l 2>/dev/null; echo "0 2 * * * snapraid-maintenance") | crontab -

# enables hdd spindown
apt install -y hdparm
cat << 'EOF' > /usr/bin/spindown
for d in /sys/block/sd*; do 
  [ -f "$d/queue/rotational" ] && [ "$(cat $d/queue/rotational)" -eq 1 ] && [ -b "/dev/$(basename $d)" ] && 
    /usr/bin/hdparm -S 242 -B 127 /dev/$(basename $d) 2>/dev/null || true; done
EOF
chmod +x /usr/bin/spindown
spindown
(crontab -l 2>/dev/null; echo "@reboot spindown") | crontab -

# enables spindown logs
cat << 'EOF' > /usr/bin/spindown-log
#!/bin/bash
LOGFILE="/var/log/disks-spin.log"
STATEFILE="/var/lib/disks-spin.state"
SUMMARY="/var/log/disks-spin-summary.log"
DATE=$(date +"%Y-%m-%d %H:%M:%S")
DAY=$(date +"%Y-%m-%d")
mkdir -p /var/lib
for dev in /dev/sd[a-z]; do
    CURR_STATE=$(hdparm -C "$dev" 2>/dev/null | awk '/drive state/ {print $NF}')
    [[ -z "$CURR_STATE" ]] && continue  # skip if no result
    PREV_STATE=$(awk -v d="$dev" '$1==d {print $2}' "$STATEFILE" 2>/dev/null)
    if [[ "$CURR_STATE" != "$PREV_STATE" ]]; then
        echo "$DATE $dev $CURR_STATE" >> "$LOGFILE"
        # count spinups / spindowns
        case "$CURR_STATE" in
            active*|idle*)  # matches "active", "active/idle", "idle"
                EVENT="SPINUP"
                ;;
            standby)
                EVENT="SPINDOWN"
                ;;
            *)
                EVENT=""
                ;;
        esac
        if [[ -n "$EVENT" ]]; then
            # Update summary: device + day + counters
            awk -v dev="$dev" -v day="$DAY" -v event="$EVENT" '
                BEGIN {found=0}
                {
                    if ($1==day && $2==dev) {
                        if (event=="SPINUP")   $3++
                        if (event=="SPINDOWN") $4++
                        found=1
                    }
                    print
                }
                END {
                    if (!found) {
                        up=(event=="SPINUP")?1:0
                        down=(event=="SPINDOWN")?1:0
                        print day, dev, up, down
                    }
                }
            ' "$SUMMARY" 2>/dev/null > "$SUMMARY.tmp"
            mv "$SUMMARY.tmp" "$SUMMARY"
            if ! grep -q "^DATE" "$SUMMARY"; then
                sed -i '1iDATE DEVICE SPINUPS SPINDOWNS' "$SUMMARY"
            fi
        fi
        # update state file
        grep -v "^$dev " "$STATEFILE" 2>/dev/null > "$STATEFILE.tmp"
        echo "$dev $CURR_STATE" >> "$STATEFILE.tmp"
        mv "$STATEFILE.tmp" "$STATEFILE"
    fi
done
EOF
chmod +x /usr/bin/spindown-log
spindown-log
(crontab -l 2>/dev/null; echo "*/15 * * * * spindown-log") | crontab -

# enables uncaching
cat << 'EOF' > /usr/bin/uncache-data
#!/bin/sh
set -eou pipefail
get_parameter() {
  _get_parameter_flag=$1 && shift
  while [ $# -ge 1 ]; do
    _get_parameter_param=$1 && shift
    [ "$_get_parameter_flag" != "$_get_parameter_param" ] && continue
    _get_parameter_val='' && [ $# -ge 1 ] && _get_parameter_val=$1
    [ -n "$_get_parameter_val" ] &&
      expr "x$_get_parameter_val" : 'x[^-]' >/dev/null &&
      echo "$_get_parameter_val"
    return 0
  done
  return 1
}
get_files() { find "$1" -not -type d -not -name '*.snapraid.content*' -printf '%A+ %p\n' | sort; }
get_usage() { df --output=pcent "$1" | tail -1 | sed 's/[^0-9]//g'; }
_pusage=$(get_parameter --pusage "$@") && [ -n "$_pusage" ] || _pusage=80
_source=$(get_parameter --source "$@") && [ -n "$_source" ] && _source="${_source%/}" || _source=/mnt/storage/fast
_target=$(get_parameter --target "$@") && [ -n "$_target" ] && _target="${_target%/}" || _target=/mnt/storage/slow
[ "$(get_usage "$_source")" -lt "$_pusage" ] && {
  printf 'Nothing to do %s %s%% ' "$_source" "$(get_usage "$_source")"
  printf 'less than target %s%% ' "$_pusage"
  echo && exit 0
}
printf 'Uncaching for %s%% usage ' "$_pusage"
printf 'from %s %s%% ' "$_source" "$(get_usage "$_source")"
printf 'to %s %s%%   ' "$_target" "$(get_usage "$_target")"
echo
_stats_counter=0
_stats_moved=0
_stats_timer_start=$(date +%s)
_source_files=$(mktemp)
get_files "$_source" >"$_source_files"
while read -r _file; do
  [ "$(get_usage "$_source")" -lt "$_pusage" ] && break
  _fpath=$(echo "$_file" | cut -d' ' -f2)
  _rpath=$(echo "$_fpath" | sed "s|^$_source/||")
  _size=$(find "$_fpath" -printf '%s')
  _stats_counter=$((_stats_counter + 1))
  _stats_moved=$((_stats_moved + _size))
  rsync -axqHAXWESR --preallocate --remove-source-files "$_source/./$_rpath" "$_target/"
  printf '%6s %5s ./%s \n' \
    "($(get_usage "$_source")%)" \
    "$(numfmt --to=iec "$_size")" \
    "$_rpath"
done <"$_source_files"
rm "$_source_files"
_stats_timer_end=$(date +%s)
printf 'Uncached '
printf '%s - %s file(s) in %s seconds \n' \
  "$(numfmt --to=iec "$_stats_moved")" \
  $_stats_counter \
  $((_stats_timer_end - _stats_timer_start))
EOF
chmod +x /usr/bin/uncache-data
uncache-data
(crontab -l 2>/dev/null; echo "@daily uncache-data") | crontab -

# setup podman
apt install -y podman
systemctl enable --now podman-restart.service podman.service podman.socket

# setup users
mkdir -p /opt/podman/samba/users
openssl rand -hex 64 > /opt/podman/samba/users/admin.key
openssl rand -hex 64 > /opt/podman/samba/users/backup.key
openssl rand -hex 64 > /opt/podman/samba/users/pbs.key
openssl rand -hex 64 > /opt/podman/samba/users/pve.key

# setup samba
mkdir -p /data/share/{public,pbs,pve}
chmod -R 777 /data/share
cat << EOF > /opt/podman/samba/config.yml
auth:
  - user: admin
    group: admin
    uid: 1000
    gid: 1000
    password: $(cat /opt/podman/samba/users/admin.key)
  - user: backup
    group: backup
    uid: 1001
    gid: 1001
    password: $(cat /opt/podman/samba/users/backup.key)
  - user: pbs
    group: pbs
    uid: 1002
    gid: 1002
    password: $(cat /opt/podman/samba/users/pbs.key)
  - user: pve
    group: pve
    uid: 1003
    gid: 1003
    password: $(cat /opt/podman/samba/users/pve.key)
share:
  - name: share
    path: /share
    guestok: no
    validusers: admin backup
    writelist: admin
    browsable: no
  - name: public
    path: /share/public
    readonly: no
  - name: pbs
    path: /share/pbs
    guestok: no
    validusers: pbs
    writelist: pbs
    browsable: no
  - name: pve
    path: /share/pve
    guestok: no
    validusers: pve
    writelist: pve
    browsable: no
EOF
podman run -d --restart always \
  --name nedi-nas \
  --hostname nedi-nas \
  --network host \
  -e AVAHI_ENABLE=1 \
  -e WSDD2_ENABLE=1 \
  -v /data/share:/share \
  -v /opt/podman/samba/config.yml:/data/config.yml \
  --health-cmd='["smbclient", "//127.0.0.1/public", "-N", "-c", "exit"]' \
  --health-on-failure restart \
  docker.io/crazymax/samba:latest

# setup hawser
mkdir -p /opt/podman/hawser
openssl rand -hex 64 > /opt/podman/hawser/token.key
podman run -d --restart always \
  --name nedi-nas-hawser \
  --network host \
  -e STACKS_DIR=/etc/hawser \
  -e TOKEN=$(cat /opt/podman/hawser/token.key) \
  -v /opt/podman/hawser:/etc/hawser \
  -v /run/podman/podman.sock:/var/run/docker.sock \
  --health-on-failure restart \
  ghcr.io/finsys/hawser:latest
cat /opt/podman/hawser/token.key

# setup firewall
apt install -y ufw
ufw default allow outgoing
ufw default deny incoming
# SSH
ufw allow from 10.0.0.0/8 to any port 22 proto tcp
ufw allow from 172.16.0.0/12 to any port 22 proto tcp
ufw allow from 192.168.0.0/16 to any port 22 proto tcp
# SMB
ufw allow from 10.0.0.0/8 to any port 445 proto tcp
ufw allow from 172.16.0.0/12 to any port 445 proto tcp
ufw allow from 192.168.0.0/16 to any port 445 proto tcp
# Hawser
ufw allow from 10.0.0.0/8 to any port 2376 proto tcp
ufw allow from 172.16.0.0/12 to any port 2376 proto tcp
ufw allow from 192.168.0.0/16 to any port 2376 proto tcp
# WSDD2
ufw allow from 10.0.0.0/8 to any port 3702
ufw allow from 172.16.0.0/12 to any port 3702
ufw allow from 192.168.0.0/16 to any port 3702
# mDNS
ufw allow from 10.0.0.0/8 to any port 5353 proto udp
ufw allow from 172.16.0.0/12 to any port 5353 proto udp
ufw allow from 192.168.0.0/16 to any port 5353 proto udp
# LLMNR
ufw allow from 10.0.0.0/8 to any port 5355
ufw allow from 172.16.0.0/12 to any port 5355
ufw allow from 192.168.0.0/16 to any port 5355
ufw enable

```
