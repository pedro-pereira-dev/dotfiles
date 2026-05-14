# `nedi-pbs`

## Details

- Cloud: Oracle
- OS: Debian 13
- IPv4: `192.168.0.22`

Ports opened:

```
root@nedi-pbs:~# ufw status verbose
Status: active
Logging: on (low)
Default: deny (incoming), allow (outgoing), disabled (routed)
New profiles: skip

To                         Action      From
--                         ------      ----
22/tcp on eth0             ALLOW IN    10.0.0.0/8
22/tcp on eth0             ALLOW IN    172.16.0.0/12
22/tcp on eth0             ALLOW IN    192.168.0.0/16
2376/tcp on eth0           ALLOW IN    10.0.0.0/8
2376/tcp on eth0           ALLOW IN    172.16.0.0/12
2376/tcp on eth0           ALLOW IN    192.168.0.0/16
8007/tcp on eth0           ALLOW IN    10.0.0.0/8
8007/tcp on eth0           ALLOW IN    172.16.0.0/12
8007/tcp on eth0           ALLOW IN    192.168.0.0/16
```

## Initial system setup

```bash
# setup basic container
bash -c "$(curl -fsSL https://raw.githubusercontent.com/community-scripts/ProxmoxVE/main/ct/debian.sh)"
pct enter 1022

# setup ssh
echo 'ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJbHkOpoucRSqD/zKiyC2xtjw0F/JeUtZlrmMuLy2iWd 11753516+pedro-pereira-dev@users.noreply.github.com' > /root/.ssh/authorized_keys
echo 'PasswordAuthentication no' > /etc/ssh/sshd_config.d/sshd.conf
echo 'X11Forwarding no' >> /etc/ssh/sshd_config.d/sshd.conf
systemctl restart ssh

## disable ipv6
#echo 'net.ipv6.conf.all.disable_ipv6 = 1' > /etc/sysctl.d/99-disable-ipv6.conf
#echo 'net.ipv6.conf.default.disable_ipv6 = 1' >> /etc/sysctl.d/99-disable-ipv6.conf
#echo 'net.ipv6.conf.lo.disable_ipv6 = 1' >> /etc/sysctl.d/99-disable-ipv6.conf
#sysctl --system

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
apt install -y build-essential crun podman ufw

# setup podman
apt install -y crun podman
systemctl enable --now podman-restart.service podman.service podman.socket

# setup libnoipv6
mkdir -p /opt/podman/libnoipv6
echo
echo '#define _GNU_SOURCE' > /opt/podman/libnoipv6/libnoipv6.c
echo '#include <sys/types.h>' >> /opt/podman/libnoipv6/libnoipv6.c
echo '#include <sys/socket.h>' >> /opt/podman/libnoipv6/libnoipv6.c
echo '#include <netinet/in.h>' >> /opt/podman/libnoipv6/libnoipv6.c
echo '#include <dlfcn.h>' >> /opt/podman/libnoipv6/libnoipv6.c
echo '#include <errno.h>' >> /opt/podman/libnoipv6/libnoipv6.c
echo '#include <string.h>' >> /opt/podman/libnoipv6/libnoipv6.c
echo 'int socket(int domain, int type, int protocol) {' >> /opt/podman/libnoipv6/libnoipv6.c
echo '    if (domain == AF_INET6) {' >> /opt/podman/libnoipv6/libnoipv6.c
echo '        domain = AF_INET; // Force IPv4' >> /opt/podman/libnoipv6/libnoipv6.c
echo '    }' >> /opt/podman/libnoipv6/libnoipv6.c
echo '    int (*orig_socket)(int, int, int) = dlsym(RTLD_NEXT, "socket");' >> /opt/podman/libnoipv6/libnoipv6.c
echo '    return orig_socket(domain, type, protocol);' >> /opt/podman/libnoipv6/libnoipv6.c
echo '}' >> /opt/podman/libnoipv6/libnoipv6.c
echo 'int bind(int sockfd, const struct sockaddr *addr, socklen_t addrlen) {' >> /opt/podman/libnoipv6/libnoipv6.c
echo '    int (*orig_bind)(int, const struct sockaddr *, socklen_t) = dlsym(RTLD_NEXT, "bind");' >> /opt/podman/libnoipv6/libnoipv6.c
echo '    if (addr->sa_family == AF_INET6) {' >> /opt/podman/libnoipv6/libnoipv6.c
echo '        struct sockaddr_in v4_addr;' >> /opt/podman/libnoipv6/libnoipv6.c
echo '        memset(&v4_addr, 0, sizeof(v4_addr));' >> /opt/podman/libnoipv6/libnoipv6.c
echo '        v4_addr.sin_family = AF_INET;' >> /opt/podman/libnoipv6/libnoipv6.c
echo '        v4_addr.sin_port = ((struct sockaddr_in6 *)addr)->sin6_port;' >> /opt/podman/libnoipv6/libnoipv6.c
echo '        v4_addr.sin_addr.s_addr = INADDR_ANY; // Translate [::] to 0.0.0.0' >> /opt/podman/libnoipv6/libnoipv6.c
echo '        return orig_bind(sockfd, (const struct sockaddr *)&v4_addr, sizeof(v4_addr));' >> /opt/podman/libnoipv6/libnoipv6.c
echo '    }' >> /opt/podman/libnoipv6/libnoipv6.c
echo '    return orig_bind(sockfd, addr, addrlen);' >> /opt/podman/libnoipv6/libnoipv6.c
echo '}' >> /opt/podman/libnoipv6/libnoipv6.c
echo
gcc -shared -fPIC -ldl /opt/podman/libnoipv6/libnoipv6.c -o /opt/podman/libnoipv6/libnoipv6.so

# setup pbs
mkdir -p /local /opt/podman/pbs
podman run -d --restart always \
  --name nedi-pbs \
  --network host \
  --tmpfs /run \
  -e LD_PRELOAD=/lib/libnoipv6.so \
  -v /local:/local \
  -v /opt/podman/libnoipv6/libnoipv6.so:/lib/libnoipv6.so:ro \
  -v /opt/podman/pbs:/etc/proxmox-backup \
  --health-cmd='["curl", "-f", "http://127.0.0.1:8007"]' \
  --health-on-failure restart \
  docker.io/ayufan/proxmox-backup-server:latest

# setup hawser
mkdir -p /opt/podman/hawser
podman run -d --restart always \
  --name nedi-pbs-hawser \
  --network host \
  -e STACKS_DIR=/etc/hawser \
  -e TOKEN=$(openssl rand -hex 64) \
  -v /opt/podman/hawser:/etc/hawser \
  -v /run/podman/podman.sock:/var/run/docker.sock \
  ghcr.io/finsys/hawser:latest
podman inspect --format='{{range .Config.Env}}{{println .}}{{end}}' nedi-pbs-hawser | grep TOKEN | cut -d= -f2

# setup firewall
apt install -y ufw
ufw default allow outgoing
ufw default deny incoming
# ssh - 22
ufw allow in on eth0 from 10.0.0.0/8 to any port 22 proto tcp
ufw allow in on eth0 from 172.16.0.0/12 to any port 22 proto tcp
ufw allow in on eth0 from 192.168.0.0/16 to any port 22 proto tcp
# hawser - 2376
ufw allow in on eth0 from 10.0.0.0/8 to any port 2376 proto tcp
ufw allow in on eth0 from 172.16.0.0/12 to any port 2376 proto tcp
ufw allow in on eth0 from 192.168.0.0/16 to any port 2376 proto tcp
# PBS - 8007
ufw allow in on eth0 from 10.0.0.0/8 to any port 8007 proto tcp
ufw allow in on eth0 from 172.16.0.0/12 to any port 8007 proto tcp
ufw allow in on eth0 from 192.168.0.0/16 to any port 8007 proto tcp
ufw enable

```
