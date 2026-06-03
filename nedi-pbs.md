# `nedi-pbs`

## Details

- Site: Personal
- OS: Debian 13
- IPv4: `192.168.0.6`

Ports opened:

```
root@nedi-pbs:~# ufw status verbose
Status: active
Logging: on (low)
Default: deny (incoming), allow (outgoing), deny (routed)
New profiles: skip

To                         Action      From
--                         ------      ----
22/tcp                     ALLOW IN    10.0.0.0/8
22/tcp                     ALLOW IN    172.16.0.0/12
22/tcp                     ALLOW IN    192.168.0.0/16
2376/tcp                   ALLOW IN    10.0.0.0/8
2376/tcp                   ALLOW IN    172.16.0.0/12
2376/tcp                   ALLOW IN    192.168.0.0/16
8007/tcp                   ALLOW IN    10.0.0.0/8
8007/tcp                   ALLOW IN    172.16.0.0/12
8007/tcp                   ALLOW IN    192.168.0.0/16
```

## Initial system setup

```bash
# creates debian lxc
bash -c "$(curl -fsSL https://raw.githubusercontent.com/community-scripts/ProxmoxVE/main/ct/debian.sh)"
# fuse - mergerfs
pct stop 1006

# add additional 64gb mountpoint to /local
pct set 1006 -mp1 /mnt/shared/nfs/pbs/nedi-pbs,mp=/share
# enable protection
pct start 1006
pct enter 1006

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

# disables ipv6 networking
cat << 'EOF' > /etc/sysctl.d/99-disable-ipv6.conf
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
cat << 'EOF' > /usr/bin/update
#!/bin/sh
apt update
apt full-upgrade -y
apt autoremove -y
EOF
chmod +x /usr/bin/update
update

# installs all required dependencies
apt install -y build-essential podman ufw

# sets up podman socket
apt install -y podman
systemctl enable --now podman-restart.service podman.service podman.socket

# builds libnoipv6
mkdir -p /opt/podman/libnoipv6
cat << 'EOF' > /opt/podman/libnoipv6/libnoipv6.c
#define _GNU_SOURCE
#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <dlfcn.h>
#include <errno.h>
#include <string.h>
int socket(int domain, int type, int protocol) {
    if (domain == AF_INET6) {
        domain = AF_INET; // Force IPv4
    }
    int (*orig_socket)(int, int, int) = dlsym(RTLD_NEXT, "socket");
    return orig_socket(domain, type, protocol);
}
int bind(int sockfd, const struct sockaddr *addr, socklen_t addrlen) {
    int (*orig_bind)(int, const struct sockaddr *, socklen_t) = dlsym(RTLD_NEXT, "bind");
    if (addr->sa_family == AF_INET6) {
        struct sockaddr_in v4_addr;
        memset(&v4_addr, 0, sizeof(v4_addr));
        v4_addr.sin_family = AF_INET;
        v4_addr.sin_port = ((struct sockaddr_in6 *)addr)->sin6_port;
        v4_addr.sin_addr.s_addr = INADDR_ANY; // Translate [::] to 0.0.0.0
        return orig_bind(sockfd, (const struct sockaddr *)&v4_addr, sizeof(v4_addr));
    }
    return orig_bind(sockfd, addr, addrlen);
}
EOF
gcc -shared -fPIC -ldl /opt/podman/libnoipv6/libnoipv6.c -o /opt/podman/libnoipv6/libnoipv6.so

# sets up pbs
mkdir -p /local /opt/podman/pbs /share
podman run -d --replace --restart always \
  --name nedi-pbs \
  --network host \
  --tmpfs /run \
  -e LD_PRELOAD=/lib/libnoipv6.so \
  -e TZ=Europe/Lisbon \
  -v /local:/local \
  -v /opt/podman/libnoipv6/libnoipv6.so:/lib/libnoipv6.so:ro \
  -v /opt/podman/pbs:/etc/proxmox-backup \
  -v /share:/share \
  --health-cmd='["curl", "-f", "http://127.0.0.1:8007"]' \
  --health-on-failure restart \
  docker.io/ayufan/proxmox-backup-server:latest
# admin / pbspbs

# sets up hawser
mkdir -p /opt/podman/hawser
openssl rand -hex 64 > /opt/podman/hawser/token.key
podman run -d --replace --restart always \
  --name nedi-pbs-hawser \
  --network host \
  -e STACKS_DIR=/etc/hawser \
  -e TOKEN=$(cat /opt/podman/hawser/token.key) \
  -v /opt/podman/hawser:/etc/hawser \
  -v /run/podman/podman.sock:/var/run/docker.sock \
  ghcr.io/finsys/hawser:latest

# sets up firewall
apt install -y ufw
ufw default allow outgoing
ufw default deny incoming
# SSH
ufw allow from 10.0.0.0/8 to any port 22 proto tcp
ufw allow from 172.16.0.0/12 to any port 22 proto tcp
ufw allow from 192.168.0.0/16 to any port 22 proto tcp
# Hawser
ufw allow from 10.0.0.0/8 to any port 2376 proto tcp
ufw allow from 172.16.0.0/12 to any port 2376 proto tcp
ufw allow from 192.168.0.0/16 to any port 2376 proto tcp
# PBS
ufw allow from 10.0.0.0/8 to any port 8007 proto tcp
ufw allow from 172.16.0.0/12 to any port 8007 proto tcp
ufw allow from 192.168.0.0/16 to any port 8007 proto tcp
ufw enable

```
