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
# fuse - nfs
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
apt install -y curl
curl -L https://enterprise.proxmox.com/debian/proxmox-archive-keyring-trixie.gpg -o /usr/share/keyrings/proxmox-archive-keyring.gpg
cat << 'EOF' > /etc/apt/sources.list.d/pve-install-repo.sources
Types: deb
URIs: http://download.proxmox.com/debian/pbs
Suites: trixie
Components: pbs-no-subscription
Signed-By: /usr/share/keyrings/proxmox-archive-keyring.gpg
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
apt install -y build-essential proxmox-backup-server ufw

# builds libnoipv6
mkdir -p /opt/libnoipv6
cat << 'EOF' > /opt/libnoipv6/libnoipv6.c
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
gcc -shared -fPIC -ldl /opt/libnoipv6/libnoipv6.c -o /opt/libnoipv6/libnoipv6.so

# sets up proxmox backup server
apt install -y proxmox-backup-server
mkdir -p /etc/systemd/system/proxmox-backup-proxy.service.d
cat << 'EOF' > /etc/systemd/system/proxmox-backup-proxy.service.d/override.conf
[Service]
Environment="LD_PRELOAD=/opt/libnoipv6/libnoipv6.so"
EOF
systemctl daemon-reload
systemctl restart proxmox-backup-proxy.service

# sets up firewall
apt install -y ufw
ufw default allow outgoing
ufw default deny incoming
# SSH
ufw allow from 10.0.0.0/8 to any port 22 proto tcp
ufw allow from 172.16.0.0/12 to any port 22 proto tcp
ufw allow from 192.168.0.0/16 to any port 22 proto tcp
# PBS
ufw allow from 10.0.0.0/8 to any port 8007 proto tcp
ufw allow from 172.16.0.0/12 to any port 8007 proto tcp
ufw allow from 192.168.0.0/16 to any port 8007 proto tcp
ufw enable

```
