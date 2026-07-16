# `nedi-nas`

## Details

- Site: Personal
- OS: Debian 13
- IPv4: `192.168.0.3`

## Initial system setup

```bash

# creates debian lxc
bash -c "$(curl -fsSL https://raw.githubusercontent.com/community-scripts/ProxmoxVE/main/ct/debian.sh)"
# privileged - mounting, fuse - mergerfs
pct stop 1003

# add additional 128gb mountpoint to /local
# add additional disks as device passthroughs, /dev/sd*1
# enable protection
# start / shutdown order 2
pct start 1003
pct enter 1003

# sets up ssh server
cat << 'EOF' > /root/.ssh/authorized_keys
ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJbHkOpoucRSqD/zKiyC2xtjw0F/JeUtZlrmMuLy2iWd 11753516+pedro-pereira-dev@users.noreply.github.com
EOF
cat << 'EOF' > /etc/ssh/sshd_config.d/sshd.conf
PasswordAuthentication no
X11Forwarding no
EOF
rm -f /etc/ssh/sshd_config.d/test.conf
systemctl restart ssh

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
cat << 'EOF' > /usr/bin/update
#!/bin/sh
apt update
apt full-upgrade -y
apt autoremove -y
EOF
chmod +x /usr/bin/update
update

# installs all required dependencies
apt install -y hdparm mergerfs nfs-kernel-server ufw

# sets up disks
apt install -y mergerfs
mkdir -p /mnt/disks/{fast-01,slow-01,slow-02}
mkdir -p /mnt/storage/{fast,slow}
mkdir -p /data
ln -fs /local /mnt/disks/fast-99
cat << EOF > /etc/fstab
UUID=3ce70563-290e-4fb4-89ec-8054bc0093c6   /mnt/disks/fast-01      ext4 defaults 0 0
UUID=73481b2e-75bb-43af-85d9-51fc0f237880   /mnt/disks/slow-01      ext4 defaults 0 0
UUID=b6583ee1-d4aa-42c2-b2ef-15baff9deb46   /mnt/disks/slow-02      ext4 defaults 0 0
$()
/mnt/disks/fast-*                           /mnt/storage/fast       mergerfs x-systemd.requires-mount-for=/mnt/disks,defaults 0 0
/mnt/disks/slow-*                           /mnt/storage/slow       mergerfs x-systemd.requires-mount-for=/mnt/disks,defaults 0 0
/mnt/disks/fast-*:/mnt/disks/slow-*         /data                   mergerfs x-systemd.requires-mount-for=/mnt/disks,defaults,category.create=ff 0 0
EOF
(crontab -l 2>/dev/null; echo '@reboot mount -a') | crontab -
systemctl daemon-reload
mount -a

# enables hdd spindown
apt install -y hdparm
cat << 'EOF' > /usr/bin/spindown
for d in /sys/block/sd*; do 
  [ -f "$d/queue/rotational" ] && [ "$(cat $d/queue/rotational)" -eq 1 ] && [ -b "/dev/$(basename $d)" ] && 
    /usr/bin/hdparm -S 242 -B 127 /dev/$(basename $d) 2>/dev/null || true; done
EOF
chmod +x /usr/bin/spindown
spindown
(crontab -l 2>/dev/null; echo '@reboot spindown') | crontab -

# sets up nfs
apt install -y nfs-kernel-server
sed -i '/^\[mountd\]/,/^\[/ s/^#\?\s*port\s*=.*/port=20048/' /etc/nfs.conf
sed -i '/^\[statd\]/,/^\[/ s/^#\?\s*port\s*=.*/port=32765/' /etc/nfs.conf
mkdir -p /data/storage/nedi/media/{media,torrents}/{movies,musics,tvshows}
mkdir -p /data/storage/nedi/pbs
chmod -R 777 /data
chown -R nobody:nogroup /data
cat << 'EOF' > /etc/exports
/data/storage 192.168.0.5/32(all_squash,anongid=0,anonuid=0,fsid=1,rw)
EOF
exportfs -ar
systemctl daemon-reload
systemctl restart nfs-kernel-server

# sets up firewall
apt install -y ufw
ufw default allow outgoing
ufw default deny incoming
# SSH
ufw allow from 10.0.0.0/8 to any port 22 proto tcp
ufw allow from 172.16.0.0/12 to any port 22 proto tcp
ufw allow from 192.168.0.0/16 to any port 22 proto tcp
# RCP
ufw allow from 10.0.0.0/8 to any port 111
ufw allow from 172.16.0.0/12 to any port 111
ufw allow from 192.168.0.0/16 to any port 111
# NFS
ufw allow from 10.0.0.0/8 to any port 2049
ufw allow from 172.16.0.0/12 to any port 2049
ufw allow from 192.168.0.0/16 to any port 2049
# Mountd
ufw allow from 10.0.0.0/8 to any port 20048
ufw allow from 172.16.0.0/12 to any port 20048
ufw allow from 192.168.0.0/16 to any port 20048
# Statd
ufw allow from 10.0.0.0/8 to any port 32765
ufw allow from 172.16.0.0/12 to any port 32765
ufw allow from 192.168.0.0/16 to any port 32765
ufw enable

```
