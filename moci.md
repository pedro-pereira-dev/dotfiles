# `moci`

## Details

- Cloud: Oracle
- OS: Debian 13
- IPv4: `79.72.63.98`

The server hosts a wireguard server, pihole for blocking domains and unbound for name resolution. Additionally, there is a rathole server for exposing private network services to the public internet from remote systems.

```
root@moci:~# lsblk -o NAME,FSTYPE,UUID,SIZE,FSAVAIL,MOUNTPOINTS
NAME           FSTYPE      UUID                                     SIZE FSAVAIL MOUNTPOINTS
sda                                                                 200G
├─sda1         vfat        271B-59E6                                 60M   55.2M /boot/efi
└─sda2         LVM2_member uzk8Kr-HS9j-3tuD-ABb0-cuKa-ggQM-3p8nGM 199.9G
  ├─vg-root    ext4        068b4e65-7635-4ee2-abc5-d27b65889708       8G    5.9G /
  ├─vg-swap    swap        6e80b9d0-c9cd-4fc3-a851-899821d270c2       1G         [SWAP]
  └─vg-storage ext4        17ed978c-5de2-4bd6-bb29-9b0b1ad55f8b   190.9G  177.3G /mnt/storage
```

Ports opened:
- public internet
  - 80/tcp    - HTTP port forward through rathole tunnel
  - 443/tcp   - HTTPS port forward through rathole tunnel
  - 3478/udp  - TURN port forward through rathole tunnel
  - 51820/udp - wireguard port forward through rathole tunnel
- oracle firewalled
  - 22/tcp    - SSH server (local)
  - 8080/tcp  - pihole webui (local)
  - 61820/udp - wireguard server (public)
- wireguard network
  - 53/udp    - DNS server (wireguard)
  - 2333/tcp  - rathole server (wireguard)

#### To do:

Restrict sensitive services to its own network interface - needed after the mesh network setup is done, (ie. ufw allow from 10.0.0.0/8 to any port 8080).
Host a storage sharing solution on /mnt/storage. Mining. Git hosting.

## Initial system setup

```bash
# setup netboot
mkdir -p /boot/efi/EFI/netboot
curl -Lfs https://boot.netboot.xyz/ipxe/netboot.xyz-arm64.efi -o /boot/efi/EFI/netboot/netboot.xyz-arm64.efi

# setup ssh
echo 'ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJbHkOpoucRSqD/zKiyC2xtjw0F/JeUtZlrmMuLy2iWd 11753516+pedro-pereira-dev@users.noreply.github.com' > /root/.ssh/authorized_keys
echo 'PasswordAuthentication no' > /etc/ssh/sshd_config.d/sshd.conf
echo 'X11Forwarding no' >> /etc/ssh/sshd_config.d/sshd.conf
systemctl restart ssh

# setup fstab
echo 'UUID=CC5B-D676          /boot/efi       vfat defaults,noatime,nodev,noexec,nosuid,umask=0077 0 2' > /etc/fstab
echo '/dev/mapper/vg-root     /               ext4 defaults,errors=remount-ro 0 1' >> /etc/fstab
echo '/dev/mapper/vg-swap     none            swap sw 0 0' >> /etc/fstab
echo '/dev/mapper/vg-data     /mnt/data       ext4 defaults 0 0' >> /etc/fstab

# disable ipv6
echo 'net.ipv6.conf.all.disable_ipv6 = 1' > /etc/sysctl.d/99-disable-ipv6.conf
echo 'net.ipv6.conf.default.disable_ipv6 = 1' >> /etc/sysctl.d/99-disable-ipv6.conf
echo 'net.ipv6.conf.lo.disable_ipv6 = 1' >> /etc/sysctl.d/99-disable-ipv6.conf
sysctl --system

# setup grub
sed -i 's/^GRUB_TIMEOUT=.*/GRUB_TIMEOUT=0/' /etc/default/grub
sed -i 's/GRUB_CMDLINE_LINUX_DEFAULT="\(.*\)"/GRUB_CMDLINE_LINUX_DEFAULT="\1 ipv6.disable=1"/' /etc/default/grub
update-grub

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
apt install -y crun podman ufw

# setup podman
apt install -y crun podman
systemctl enable --now podman-restart.service
systemctl enable --now podman.service
systemctl enable --now podman.socket

# setup unbound
mkdir -p /etc/unbound
echo
echo 'server:' > /etc/unbound/unbound.conf
echo '  access-control: 10.0.0.0/8 allow' >> /etc/unbound/unbound.conf
echo '  access-control: 169.254.0.0/16 allow' >> /etc/unbound/unbound.conf
echo '  access-control: 172.16.0.0/12 allow' >> /etc/unbound/unbound.conf
echo '  access-control: 192.168.0.0/16 allow' >> /etc/unbound/unbound.conf
echo '  cache-max-ttl: 14400' >> /etc/unbound/unbound.conf
echo '  cache-min-ttl: 300' >> /etc/unbound/unbound.conf
echo '  do-ip6: no' >> /etc/unbound/unbound.conf
echo '  harden-referral-path: yes' >> /etc/unbound/unbound.conf
echo '  hide-identity: yes' >> /etc/unbound/unbound.conf
echo '  hide-version: yes' >> /etc/unbound/unbound.conf
echo '  interface: 0.0.0.0' >> /etc/unbound/unbound.conf
echo '  key-cache-size: 256m' >> /etc/unbound/unbound.conf
echo '  msg-cache-size: 256m' >> /etc/unbound/unbound.conf
echo '  neg-cache-size: 256m' >> /etc/unbound/unbound.conf
echo '  port: 5353' >> /etc/unbound/unbound.conf
echo '  prefetch-key: yes' >> /etc/unbound/unbound.conf
echo '  prefetch: yes' >> /etc/unbound/unbound.conf
echo '  private-address: 10.0.0.0/8' >> /etc/unbound/unbound.conf
echo '  private-address: 169.254.0.0/16' >> /etc/unbound/unbound.conf
echo '  private-address: 172.16.0.0/12' >> /etc/unbound/unbound.conf
echo '  private-address: 192.168.0.0/16' >> /etc/unbound/unbound.conf
echo '  rrset-cache-size: 256m' >> /etc/unbound/unbound.conf
echo '  so-sndbuf: 0' >> /etc/unbound/unbound.conf
echo '  verbosity: 0' >> /etc/unbound/unbound.conf
echo
podman run -d --restart always --name moci-pihole-unbound \
  --network host \
  -v /etc/unbound/unbound.conf:/etc/unbound/unbound.conf \
  docker.io/alpinelinux/unbound:latest

# setup pihole
mkdir -p /etc/pihole
podman run -d --restart always --name moci-pihole-pihole \
  --hostname moci-pihole \
  --network host \
  -e FTLCONF_dns_domainNeeded=true \
  -e FTLCONF_dns_domain_name='' \
  -e FTLCONF_dns_expandHosts=true \
  -e FTLCONF_dns_piholePTR=HOSTNAME \
  -e FTLCONF_dns_upstreams=127.0.0.1#5353 \
  -e FTLCONF_ntp_ipv4_active=false \
  -e FTLCONF_ntp_ipv6_active=false \
  -e FTLCONF_ntp_sync_active=false \
  -e FTLCONF_webserver_api_password='' \
  -e FTLCONF_webserver_domain=pihole.moci.boarede.com \
  -e FTLCONF_webserver_port=8080o \
  -v /etc/pihole:/etc/pihole \
  docker.io/pihole/pihole:latest

# setup firewall
apt install -y ufw
ufw default allow outgoing
ufw default deny incoming
# public internet - 80, 443, 3478, 51820
#ufw allow 80/tcp # HTTP
#ufw allow 443/tcp # HTTPS
#ufw allow 3478/udp # TURN
#ufw allow 51820/udp # wireguard
# oracle firewalled - 22, 8080, 61820
ufw allow 22/tcp # SSH
ufw allow 8080/tcp # pihole webui
#ufw allow 61820/udp # wireguard server
# wireguard network - 53, 2333
#ufw allow in on wg0 from 10.100.100.0/24 to any port 53 proto udp # DNS
#ufw allow in on wg0 from 10.100.100.0/24 to any port 2333 proto tcp # rathole server
ufw enable




# WIP

# setup wireguard
apt install -y ufw wireguard
sed -i 's/^#\(net\/ipv4\/ip_forward=1\)/\1/' /etc/ufw/sysctl.conf
cd /etc/wireguard
umask 077
wg genkey | tee wgserver.key | wg pubkey > wgserver.pub
echo
echo '[Interface]' > /etc/wireguard/wg0.conf
echo 'Address = 10.100.100.1/24' >> /etc/wireguard/wg0.conf
echo 'ListenPort = 61820' >> /etc/wireguard/wg0.conf
echo "PrivateKey = $(cat /etc/wireguard/wgserver.key)" >> /etc/wireguard/wg0.conf
echo '' >> /etc/wireguard/wg0.conf
echo 'PostDown = iptables -D FORWARD -i wg0 -o enp0s6 -j ACCEPT' >> /etc/wireguard/wg0.conf
echo 'PostDown = iptables -t nat -D POSTROUTING -o enp0s6 -j MASQUERADE' >> /etc/wireguard/wg0.conf
echo 'PostUp = iptables -I FORWARD -i wg0 -o enp0s6 -j ACCEPT' >> /etc/wireguard/wg0.conf
echo 'PostUp = iptables -t nat -I POSTROUTING -o enp0s6 -j MASQUERADE' >> /etc/wireguard/wg0.conf
echo '' >> /etc/wireguard/wg0.conf
echo '[Peer]' >> /etc/wireguard/wg0.conf
echo 'AllowedIPs = 10.100.100.70/32' >> /etc/wireguard/wg0.conf
echo 'PublicKey = ' >> /etc/wireguard/wg0.conf
echo
systemctl enable wg-quick@wg0.service
systemctl daemon-reload
systemctl start wg-quick@wg0


# setup pihole
apt install -y curl
curl -sSL https://install.pi-hole.net | bash
# choose wg0 and 127.0.0.1#5335
# pihole setpassword PASSWORD
echo
echo '' >> /etc/dhcpcd.conf
echo 'static domain_name_servers=127.0.0.1' >> /etc/dhcpcd.conf
systemctl restart networking
systemctl reboot

# setup rathole
echo
echo '#!/bin/sh' > /usr/bin/update-rathole
echo 'curl -Lfs "$(' >> /usr/bin/update-rathole
echo '  curl -s https://api.github.com/repos/rathole-org/rathole/releases/latest |' >> /usr/bin/update-rathole
echo "    jq -r --arg ARCH \"$(uname -m)\" --arg OS \"$(uname -s | tr '[:upper:]' '[:lower:]')\" \\" >> /usr/bin/update-rathole
echo "      '.assets[] | select(.name | contains(\$ARCH) and contains(\$OS)) | .browser_download_url'" >> /usr/bin/update-rathole
echo ')" -o /tmp/rathole.zip' >> /usr/bin/update-rathole
echo 'unzip -o /tmp/rathole.zip -d /usr/bin/ >/dev/null' >> /usr/bin/update-rathole
echo 'chmod +x /usr/bin/rathole' >> /usr/bin/update-rathole
echo 'rm -fr /tmp/rathole.zip' >> /usr/bin/update-rathole
echo
chmod +x /usr/bin/update-rathole
/usr/bin/update-rathole
mkdir -p /etc/rathole
_secret=$(openssl rand -hex 64)
echo
echo '[server]' > /etc/rathole/rathole.toml
echo 'bind_addr = "10.100.100.1:2333"' >> /etc/rathole/rathole.toml
echo "default_token = \"$_secret\"" >> /etc/rathole/rathole.toml
echo '[server.services.http]' >> /etc/rathole/rathole.toml
echo 'bind_addr = "0.0.0.0:80"' >> /etc/rathole/rathole.toml
echo '[server.services.https]' >> /etc/rathole/rathole.toml
echo 'bind_addr = "0.0.0.0:443"' >> /etc/rathole/rathole.toml
echo '[server.services.turn]' >> /etc/rathole/rathole.toml
echo 'bind_addr = "0.0.0.0:3478"' >> /etc/rathole/rathole.toml
echo '[server.services.wireguard]' >> /etc/rathole/rathole.toml
echo 'bind_addr = "0.0.0.0:51820"' >> /etc/rathole/rathole.toml
echo
echo '[Unit]' > /etc/systemd/system/rathole.service
echo 'Description=Rathole Server Service' >> /etc/systemd/system/rathole.service
echo 'After=network.target' >> /etc/systemd/system/rathole.service
echo '' >> /etc/systemd/system/rathole.service
echo '[Service]' >> /etc/systemd/system/rathole.service
echo 'Type=simple' >> /etc/systemd/system/rathole.service
echo 'ExecStart=/usr/bin/rathole /etc/rathole/rathole.toml' >> /etc/systemd/system/rathole.service
echo 'Restart=on-failure' >> /etc/systemd/system/rathole.service
echo 'RestartSec=5s' >> /etc/systemd/system/rathole.service
echo '' >> /etc/systemd/system/rathole.service
echo '[Install]' >> /etc/systemd/system/rathole.service
echo 'WantedBy=multi-user.target' >> /etc/systemd/system/rathole.service
echo
systemctl enable rathole.service
systemctl daemon-reload
systemctl start rathole.service

# add dependencies
apt install -y btop fastfetch

# install netbird
bash -c "$(curl -fsSL https://pkgs.netbird.io/install.sh)"
netbird up --management-url https://netbird.boarede.com --setup-key SECRET_KEY_TOKEN

# setup nginx-proxy-manager
mkdir -p /etc/nginx-proxy-manager
podman run -d --restart always --name moci-nginx-proxy-manager \
  --network host \
  -e DISABLE_IPV6='true' \
  -v /etc/nginx-proxy-manager:/data \
  -v /etc/nginx-proxy-manager:/etc/letsencrypt \
  docker.io/jc21/nginx-proxy-manager:latest

# setup wireguard-server
mkdir -p /etc/wireguard-server
podman run --restart always --name moci-wireguard-server \
  --network host \
  --cap-add=NET_ADMIN \
  -v /etc/wireguard-server:/config \
  docker.io/linuxserver/wireguard:latest

```
