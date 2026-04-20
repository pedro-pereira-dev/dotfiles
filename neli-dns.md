# `neli-dns`

## Details

- Site: Personal
- OS: Debian 13
- IPv4: `192.168.0.2`

Containerized Unbound / Pihole service for preferred name resolution server in home network.

Ports opened:
- local network
  - 53/udp    - DNS server

#### To do:

TBD.

## Initial system setup

```bash
# setup basic container
bash -c "$(curl -fsSL https://raw.githubusercontent.com/community-scripts/ProxmoxVE/main/ct/pihole.sh)"
pct enter 1002

# setup ssh
echo 'PasswordAuthentication no' > /etc/ssh/sshd_config.d/sshd.conf
echo 'X11Forwarding no' >> /etc/ssh/sshd_config.d/sshd.conf
systemctl restart ssh

# setup apt
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

# setup unbound
rm -f /etc/unbound/unbound.conf.d/pi-hole.conf
echo
echo 'server:' > /etc/unbound/unbound.conf.d/local.conf
echo '  access-control: 192.168.0.0/24 allow' >> /etc/unbound/unbound.conf.d/local.conf
echo '  cache-max-ttl: 14400' >> /etc/unbound/unbound.conf.d/local.conf
echo '  cache-min-ttl: 300' >> /etc/unbound/unbound.conf.d/local.conf
echo '  harden-referral-path: yes' >> /etc/unbound/unbound.conf.d/local.conf
echo '  hide-identity: yes' >> /etc/unbound/unbound.conf.d/local.conf
echo '  hide-version: yes' >> /etc/unbound/unbound.conf.d/local.conf
echo '  key-cache-size: 256m' >> /etc/unbound/unbound.conf.d/local.conf
echo '  msg-cache-size: 256m' >> /etc/unbound/unbound.conf.d/local.conf
echo '  neg-cache-size: 256m' >> /etc/unbound/unbound.conf.d/local.conf
echo '  port: 5335' >> /etc/unbound/unbound.conf.d/local.conf
echo '  prefetch-key: yes' >> /etc/unbound/unbound.conf.d/local.conf
echo '  prefetch: yes' >> /etc/unbound/unbound.conf.d/local.conf
echo '  private-address: 10.0.0.0/8' >> /etc/unbound/unbound.conf.d/local.conf
echo '  private-address: 169.254.0.0/16' >> /etc/unbound/unbound.conf.d/local.conf
echo '  private-address: 172.16.0.0/12' >> /etc/unbound/unbound.conf.d/local.conf
echo '  private-address: 192.168.0.0/16' >> /etc/unbound/unbound.conf.d/local.conf
echo '  rrset-cache-size: 256m' >> /etc/unbound/unbound.conf.d/local.conf
echo '  verbosity: 0' >> /etc/unbound/unbound.conf.d/local.conf
echo
systemctl restart unbound

# remove helper scripts conf
rm -f /etc/dnsmasq.d/*

# setup pihole
rm -fr /etc/pihole/*
pihole -r
# 127.0.0.1#5335
# pihole setpassword PASSWORD
systemctl restart pihole-FTL.service

# setup firewall
apt install -y ufw
ufw default allow outgoing
ufw default deny incoming
# ssh - 22
ufw allow in on eth0 from 10.0.0.0/8 to any port 22 proto tcp
ufw allow in on eth0 from 172.16.0.0/12 to any port 22 proto tcp
ufw allow in on eth0 from 192.168.0.0/16 to any port 22 proto tcp
# dns - 53
ufw allow in on eth0 from 10.0.0.0/8 to any port 53 proto udp
ufw allow in on eth0 from 172.16.0.0/12 to any port 53 proto udp
ufw allow in on eth0 from 192.168.0.0/16 to any port 53 proto udp
# pihole webui - 8080
ufw allow in on eth0 from 10.0.0.0/8 to any port 8080 proto tcp
ufw allow in on eth0 from 172.16.0.0/12 to any port 8080 proto tcp
ufw allow in on eth0 from 192.168.0.0/16 to any port 8080 proto tcp
ufw enable
```
