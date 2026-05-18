# `nedi-nas`

## Details

- Site: Personal
- OS: Debian 13
- IPv4: `192.168.0.45`

Ports opened:

```
root@nedi-nas:~# ufw status verbose
Status: active
Logging: on (low)
Default: deny (incoming), allow (outgoing), disabled (routed)
New profiles: skip

To                         Action      From
--                         ------      ----
22/tcp                     ALLOW IN    10.0.0.0/8
22/tcp                     ALLOW IN    172.16.0.0/12
22/tcp                     ALLOW IN    192.168.0.0/16
111                        ALLOW IN    10.0.0.0/8
111                        ALLOW IN    172.16.0.0/12
111                        ALLOW IN    192.168.0.0/16
2049                       ALLOW IN    10.0.0.0/8
2049                       ALLOW IN    172.16.0.0/12
2049                       ALLOW IN    192.168.0.0/16
20048                      ALLOW IN    10.0.0.0/8
20048                      ALLOW IN    172.16.0.0/12
20048                      ALLOW IN    192.168.0.0/16
32765                      ALLOW IN    10.0.0.0/8
32765                      ALLOW IN    172.16.0.0/12
32765                      ALLOW IN    192.168.0.0/16
```

## Initial system setup

```bash
# setup basic container
bash -c "$(curl -fsSL https://raw.githubusercontent.com/community-scripts/ProxmoxVE/main/ct/debian.sh)"
# privileged and fuse
pct enter 1045
exit

# setup configuration
pct stop 1045
echo
echo 'lxc.cgroup2.devices.allow: b 8:* rwm' >> /etc/pve/lxc/1045.conf
echo 'lxc.mount.entry: /dev/sdb           dev/sdb           none bind,optional,create=file' >> /etc/pve/lxc/1045.conf
echo 'lxc.mount.entry: /dev/sdb1          dev/sdb1          none bind,optional,create=file' >> /etc/pve/lxc/1045.conf
echo 'lxc.mount.entry: /dev/sdc           dev/sdc           none bind,optional,create=file' >> /etc/pve/lxc/1045.conf
echo 'lxc.mount.entry: /dev/sdc1          dev/sdc1          none bind,optional,create=file' >> /etc/pve/lxc/1045.conf
echo 'lxc.mount.entry: /dev/sdd           dev/sdd           none bind,optional,create=file' >> /etc/pve/lxc/1045.conf
echo 'lxc.mount.entry: /dev/sdd1          dev/sdd1          none bind,optional,create=file' >> /etc/pve/lxc/1045.conf
echo
pct start 1045
pct enter 1045

# setup ssh
echo 'ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJbHkOpoucRSqD/zKiyC2xtjw0F/JeUtZlrmMuLy2iWd 11753516+pedro-pereira-dev@users.noreply.github.com' > /root/.ssh/authorized_keys
echo 'PasswordAuthentication no' > /etc/ssh/sshd_config.d/sshd.conf
echo 'X11Forwarding no' >> /etc/ssh/sshd_config.d/sshd.conf
systemctl restart ssh

# disable ipv6
echo 'net.ipv6.conf.all.disable_ipv6 = 1' > /etc/sysctl.d/99-disable-ipv6.conf
echo 'net.ipv6.conf.default.disable_ipv6 = 1' >> /etc/sysctl.d/99-disable-ipv6.conf
echo 'net.ipv6.conf.lo.disable_ipv6 = 1' >> /etc/sysctl.d/99-disable-ipv6.conf
sysctl --system

# setup apt
rm -f /etc/apt/sources.list /etc/apt/sources.list~ /etc/apt/sources.list.bak
echo
echo 'Types: deb' > /etc/apt/sources.list.d/debian.sources
echo 'URIs: http://deb.debian.org/debian/' >> /etc/apt/sources.list.d/debian.sources
echo 'Suites: trixie' >> /etc/apt/sources.list.d/debian.sources
echo 'Components: main' >> /etc/apt/sources.list.d/debian.sources
echo 'Signed-By: /usr/share/keyrings/debian-archive-keyring.gpg' >> /etc/apt/sources.list.d/debian.sources
echo '' >> /etc/apt/sources.list.d/debian.sources
echo 'Types: deb' >> /etc/apt/sources.list.d/debian.sources
echo 'URIs: http://deb.debian.org/debian/' >> /etc/apt/sources.list.d/debian.sources
echo 'Suites: trixie-updates' >> /etc/apt/sources.list.d/debian.sources
echo 'Components: main' >> /etc/apt/sources.list.d/debian.sources
echo 'Signed-By: /usr/share/keyrings/debian-archive-keyring.gpg' >> /etc/apt/sources.list.d/debian.sources
echo '' >> /etc/apt/sources.list.d/debian.sources
echo 'Types: deb' >> /etc/apt/sources.list.d/debian.sources
echo 'URIs: http://security.debian.org/debian-security/' >> /etc/apt/sources.list.d/debian.sources
echo 'Suites: trixie-security' >> /etc/apt/sources.list.d/debian.sources
echo 'Components: main' >> /etc/apt/sources.list.d/debian.sources
echo 'Signed-By: /usr/share/keyrings/debian-archive-keyring.gpg' >> /etc/apt/sources.list.d/debian.sources
echo
apt update
apt full-upgrade -y

# setup update scripts
echo
echo '#!/bin/sh' > /usr/bin/update
echo 'apt update' >> /usr/bin/update
echo 'apt full-upgrade -y' >> /usr/bin/update
echo 'apt autoremove -y' >> /usr/bin/update
echo
chmod +x /usr/bin/update

# install dependencies
apt install -y hdparm mergerfs nfs-kernel-server snapraid ufw

# setup disks
mkdir -p /mnt/disks/fast-01 /mnt/disks/slow-01 /mnt/disks/parity-01
echo
echo 'UUID=39a0ece3-e591-4076-b9fa-18623e9441ff     /mnt/disks/fast-01      ext4 defaults 0 0' > /etc/fstab
echo 'UUID=3d2a00d4-0650-4a0c-af1c-30e814922cda     /mnt/disks/slow-01      ext4 defaults 0 0' >> /etc/fstab
echo 'UUID=ce94c2e2-b0e7-40c0-89a0-1846bc567155     /mnt/disks/parity-01    ext4 defaults 0 0' >> /etc/fstab
echo
systemctl daemon-reload
mount -a

# setup mergerfs
apt install -y mergerfs
mkdir -p /mnt/storage/fast /mnt/storage/slow /mnt/storage/data
echo
echo '' >> /etc/fstab
echo '/mnt/disks/fast-*                             /mnt/storage/fast       mergerfs defaults 0 0' >> /etc/fstab
echo '/mnt/disks/slow-*                             /mnt/storage/slow       mergerfs defaults 0 0' >> /etc/fstab
echo '/mnt/disks/fast-*:/mnt/disks/slow-*           /mnt/storage/data       mergerfs defaults,category.create=ff 0 0' >> /etc/fstab
echo
systemctl daemon-reload
mount -a

# enable mergerfs
echo
echo '[Unit]' > /etc/systemd/system/remount-fstab.service
echo 'Description=Remount /etc/fstab on Boot' >> /etc/systemd/system/remount-fstab.service
echo 'After=local-fs.target' >> /etc/systemd/system/remount-fstab.service
echo '' >> /etc/systemd/system/remount-fstab.service
echo '[Service]' >> /etc/systemd/system/remount-fstab.service
echo 'Type=oneshot' >> /etc/systemd/system/remount-fstab.service
echo 'ExecStart=/bin/mount -a' >> /etc/systemd/system/remount-fstab.service
echo 'RemainAfterExit=yes' >> /etc/systemd/system/remount-fstab.service
echo '' >> /etc/systemd/system/remount-fstab.service
echo '[Install]' >> /etc/systemd/system/remount-fstab.service
echo 'WantedBy=multi-user.target' >> /etc/systemd/system/remount-fstab.service
echo
systemctl daemon-reload
systemctl enable --now remount-fstab.service

# setup snapraid
apt install -y snapraid
echo
echo 'autosave 64' > /etc/snapraid.conf
echo 'disk fast-01 /mnt/disks/fast-01' >> /etc/snapraid.conf
echo 'disk slow-01 /mnt/disks/slow-01' >> /etc/snapraid.conf
echo 'content /mnt/disks/.snapraid.content' >> /etc/snapraid.conf
echo 'content /mnt/disks/fast-01/.snapraid.content' >> /etc/snapraid.conf
echo 'content /mnt/disks/slow-01/.snapraid.content' >> /etc/snapraid.conf
echo 'parity /mnt/disks/parity-01/.snapraid.parity' >> /etc/snapraid.conf
echo
snapraid sync

# setup snapraid maintenance
echo
echo '#!/bin/bash' > /usr/bin/maintain-snapraid
echo 'set -euo pipefail' >> /usr/bin/maintain-snapraid
echo '' >> /usr/bin/maintain-snapraid
echo 'snapraid_lockfile=/run/maintain-snapraid.lock' >> /usr/bin/maintain-snapraid
echo 'snapraid_maintenance_lock_fd=9' >> /usr/bin/maintain-snapraid
echo 'snapraid_logfile=/var/log/maintain-snapraid.log' >> /usr/bin/maintain-snapraid
echo '' >> /usr/bin/maintain-snapraid
echo "log_message() { echo \"[\$(date '+%Y-%m-%d %H:%M:%S')] \$1\" | tee -a \"\$snapraid_logfile\"; }" >> /usr/bin/maintain-snapraid
echo '' >> /usr/bin/maintain-snapraid
echo '! command -v snapraid >/dev/null 2>&1 && log_message "snapraid not found" && exit 1' >> /usr/bin/maintain-snapraid
echo '! exec {snapraid_maintenance_lock_fd}>"$snapraid_lockfile" && exit 1' >> /usr/bin/maintain-snapraid
echo '! flock -n "$snapraid_maintenance_lock_fd" && log_message "Another instance is running" && exit 0' >> /usr/bin/maintain-snapraid
echo '' >> /usr/bin/maintain-snapraid
echo 'log_message "Starting snapraid maintenance"' >> /usr/bin/maintain-snapraid
echo 'snapraid sync 2>&1 | tee -a "$snapraid_logfile" || true' >> /usr/bin/maintain-snapraid
echo 'snapraid scrub 2>&1 | tee -a "$snapraid_logfile" || true' >> /usr/bin/maintain-snapraid
echo 'snapraid status 2>&1 | tee -a "$snapraid_logfile" || true' >> /usr/bin/maintain-snapraid
echo 'log_message "Completed snapraid maintenance"' >> /usr/bin/maintain-snapraid
echo
echo '/var/log/maintain-snapraid.log {' > /etc/logrotate.d/maintain-snapraid
echo '    create' >> /etc/logrotate.d/maintain-snapraid
echo '    missingok' >> /etc/logrotate.d/maintain-snapraid
echo '    notifempty' >> /etc/logrotate.d/maintain-snapraid
echo '    rotate 1' >> /etc/logrotate.d/maintain-snapraid
echo '    size 20M' >> /etc/logrotate.d/maintain-snapraid
echo '}' >> /etc/logrotate.d/maintain-snapraid
echo
chmod +x /usr/bin/maintain-snapraid
(crontab -l 2>/dev/null; echo "0 2 * * * (sleep 60 && /usr/bin/maintain-snapraid)") | crontab -

# setup nfs
apt install -y nfs-kernel-server
mkdir -p /etc/systemd/system/nfs-kernel-server.service.d /mnt/storage/data/nfs
ln -fs /mnt/storage/data/nfs /nfs
echo
echo '[Unit]' > /etc/systemd/system/nfs-kernel-server.service.d/override.conf
echo 'Requires=remount-fstab.service' >> /etc/systemd/system/nfs-kernel-server.service.d/override.conf
echo 'After=remount-fstab.service' >> /etc/systemd/system/nfs-kernel-server.service.d/override.conf
echo
sed -i '/^\[mountd\]/,/^\[/ s/^#\?\s*port\s*=.*/port=20048/' /etc/nfs.conf
sed -i '/^\[statd\]/,/^\[/ s/^#\?\s*port\s*=.*/port=32765/' /etc/nfs.conf
echo
(cd /mnt/storage/data/nfs && mkdir -p public)
chmod 777 /mnt/storage/data/nfs
chown -R nobody:nogroup /mnt/storage/data/nfs
echo
echo '/nfs 192.168.0.0/24(insecure,fsid=root,ro)' > /etc/exports
echo '/nfs/public 192.168.0.0/24(insecure,fsid=1,nohide,rw)' >> /etc/exports
echo
systemctl daemon-reload
systemctl enable --now remount-fstab.service
systemctl restart nfs-kernel-server

# enable hdd spindown
apt install -y hdparm
echo
echo '[Unit]' > /etc/systemd/system/spindown-devices.service
echo 'Description=Spindown all HDDs after one hour idle' >> /etc/systemd/system/spindown-devices.service
echo 'After=local-fs.target systemd-udev-settle.service' >> /etc/systemd/system/spindown-devices.service
echo '' >> /etc/systemd/system/spindown-devices.service
echo '[Service]' >> /etc/systemd/system/spindown-devices.service
echo 'Type=oneshot' >> /etc/systemd/system/spindown-devices.service
echo "ExecStart=/bin/sh -c 'for d in /sys/block/sd*; do [ -f \"\$d/queue/rotational\" ] && [ \"\$(cat \$d/queue/rotational)\" -eq 1 ] && [ -b \"/dev/\$(basename \$d)\" ] && /usr/bin/hdparm -S 242 -B 127 /dev/\$(basename \$d) 2>/dev/null || true; done'" >> /etc/systemd/system/spindown-devices.service
echo '' >> /etc/systemd/system/spindown-devices.service
echo '[Install]' >> /etc/systemd/system/spindown-devices.service
echo 'WantedBy=multi-user.target' >> /etc/systemd/system/spindown-devices.service
echo
systemctl daemon-reload
systemctl enable --now spindown-devices.service

# enable logging spindown
echo
echo '#!/bin/bash' > /usr/bin/log-spindown
echo 'logger_logfile=/var/log/spindown-state.log' >> /usr/bin/log-spindown
echo 'logger_statefile=/var/lib/disks-spin.state' >> /usr/bin/log-spindown
echo 'logger_summary=/var/log/spindown-summary.log' >> /usr/bin/log-spindown
echo 'DATE=$(date +"%Y-%m-%d %H:%M:%S")' >> /usr/bin/log-spindown
echo 'DAY=$(date +"%Y-%m-%d")' >> /usr/bin/log-spindown
echo '' >> /usr/bin/log-spindown
echo 'mkdir -p /var/lib' >> /usr/bin/log-spindown
echo 'for dev in /dev/sd[a-z]; do' >> /usr/bin/log-spindown
echo '  CURR_STATE=$(hdparm -C "$dev" 2>/dev/null | awk "/drive state/ {print $NF}")' >> /usr/bin/log-spindown
echo '  [[ -z "$CURR_STATE" ]] && continue' >> /usr/bin/log-spindown
echo "  PREV_STATE=\$(awk -v d=\"\$dev\" '\$1==d {print \$2}' \"\$logger_statefile\" 2>/dev/null)" >> /usr/bin/log-spindown
echo '  if [[ "$CURR_STATE" != "$PREV_STATE" ]]; then' >> /usr/bin/log-spindown
echo '    echo "$DATE $dev $CURR_STATE" >>"$logger_logfile"' >> /usr/bin/log-spindown
echo '    case "$CURR_STATE" in' >> /usr/bin/log-spindown
echo '    active* | idle*) EVENT="SPINUP" ;;' >> /usr/bin/log-spindown
echo '    standby) EVENT="SPINDOWN" ;;' >> /usr/bin/log-spindown
echo '    *) EVENT="" ;;' >> /usr/bin/log-spindown
echo '    esac' >> /usr/bin/log-spindown
echo '    if [[ -n "$EVENT" ]]; then' >> /usr/bin/log-spindown
echo "      awk -v dev=\"\$dev\" -v day=\"\$DAY\" -v event=\"\$EVENT\" '" >> /usr/bin/log-spindown
echo '                BEGIN {found=0}' >> /usr/bin/log-spindown
echo '                {' >> /usr/bin/log-spindown
echo '                    if ($1==day && $2==dev) {' >> /usr/bin/log-spindown
echo '                        if (event=="SPINUP")   $3++' >> /usr/bin/log-spindown
echo '                        if (event=="SPINDOWN") $4++' >> /usr/bin/log-spindown
echo '                        found=1' >> /usr/bin/log-spindown
echo '                    }' >> /usr/bin/log-spindown
echo '                    print' >> /usr/bin/log-spindown
echo '                }' >> /usr/bin/log-spindown
echo '                END {' >> /usr/bin/log-spindown
echo '                    if (!found) {' >> /usr/bin/log-spindown
echo '                        up=(event=="SPINUP")?1:0' >> /usr/bin/log-spindown
echo '                        down=(event=="SPINDOWN")?1:0' >> /usr/bin/log-spindown
echo '                        print day, dev, up, down' >> /usr/bin/log-spindown
echo '                    }' >> /usr/bin/log-spindown
echo '                }' >> /usr/bin/log-spindown
echo "            ' \"\$logger_summary\" 2>/dev/null >\"\$logger_summary.tmp\"" >> /usr/bin/log-spindown
echo '      mv "$logger_summary.tmp" "$logger_summary"' >> /usr/bin/log-spindown
echo '      if ! grep -q "^DATE" "$logger_summary"; then' >> /usr/bin/log-spindown
echo '        sed -i "1iDATE DEVICE SPINUPS SPINDOWNS" "$logger_summary"' >> /usr/bin/log-spindown
echo '      fi' >> /usr/bin/log-spindown
echo '    fi' >> /usr/bin/log-spindown
echo '    grep -v "^$dev " "$logger_statefile" 2>/dev/null >"$logger_statefile.tmp"' >> /usr/bin/log-spindown
echo '    echo "$dev $CURR_STATE" >>"$logger_statefile.tmp"' >> /usr/bin/log-spindown
echo '    mv "$logger_statefile.tmp" "$logger_statefile"' >> /usr/bin/log-spindown
echo '  fi' >> /usr/bin/log-spindown
echo 'done' >> /usr/bin/log-spindown
echo
echo '/var/log/spindown-state.log {' > /etc/logrotate.d/spindown-state
echo '    create' >> /etc/logrotate.d/spindown-state
echo '    missingok' >> /etc/logrotate.d/spindown-state
echo '    notifempty' >> /etc/logrotate.d/spindown-state
echo '    rotate 1' >> /etc/logrotate.d/spindown-state
echo '    size 20M' >> /etc/logrotate.d/spindown-state
echo '}' >> /etc/logrotate.d/spindown-state
echo
echo '/var/log/spindown-summary.log {' > /etc/logrotate.d/spindown-summary
echo '    create' >> /etc/logrotate.d/spindown-summary
echo '    missingok' >> /etc/logrotate.d/spindown-summary
echo '    notifempty' >> /etc/logrotate.d/spindown-summary
echo '    rotate 1' >> /etc/logrotate.d/spindown-summary
echo '    size 20M' >> /etc/logrotate.d/spindown-summary
echo '}' >> /etc/logrotate.d/spindown-summary
echo
chmod +x /usr/bin/log-spindown
(crontab -l 2>/dev/null; echo "*/15 * * * * (sleep 60 && /usr/bin/maintain-snapraid)") | crontab -

# setup duncache
# copy script into machine to /usr/bin/uncache-data
chmod +x /usr/bin/uncache-data
(crontab -l 2>/dev/null; echo "@daily (sleep 60 && /usr/bin/uncache-data)") | crontab -

# setup firewall
apt install -y ufw
ufw default allow outgoing
ufw default deny incoming
# SSH
ufw allow from 10.0.0.0/8 to any port 22 proto tcp
ufw allow from 172.16.0.0/12 to any port 22 proto tcp
ufw allow from 192.168.0.0/16 to any port 22 proto tcp
# rcpbind
ufw allow from 10.0.0.0/8 to any port 111
ufw allow from 172.16.0.0/12 to any port 111
ufw allow from 192.168.0.0/16 to any port 111
# NFS
ufw allow from 10.0.0.0/8 to any port 2049
ufw allow from 172.16.0.0/12 to any port 2049
ufw allow from 192.168.0.0/16 to any port 2049
# mountd
ufw allow from 10.0.0.0/8 to any port 20048
ufw allow from 172.16.0.0/12 to any port 20048
ufw allow from 192.168.0.0/16 to any port 20048
# statd
ufw allow from 10.0.0.0/8 to any port 32765
ufw allow from 172.16.0.0/12 to any port 32765
ufw allow from 192.168.0.0/16 to any port 32765
ufw enable

```
