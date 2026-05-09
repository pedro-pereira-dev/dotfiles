# dotfiles

My custom system dotfiles - *_WORK IN PROGRESS_*

## Proxmox

```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/pedro-pereira-dev/dotfiles/refs/heads/main/restore-host-from)"
```

## Linux

```bash
curl -Lfs -- https://raw.githubusercontent.com/pedro-pereira-dev/dotfiles/refs/heads/main/dots.sh | sh -s -- install


bash <(wget -qO - https://raw.githubusercontent.com/pedro-pereira-dev/dotfiles/refs/heads/main/dots)

curl -Lfs https://raw.githubusercontent.com/pedro-pereira-dev/dotfiles/refs/heads/main/dots | sh -s -- install ...
```

## Keys

Encrypt and decrypt:

```bash
gpg --pinentry-mode loopback --symmetric input.tar
gpg --pinentry-mode loopback --decrypt input.tar.gpg > output.tar
```

Tar and untar:

```bash
tar -czvf output.tar directory
tar -xvf input.tar
```

    MAKEOPTS equal to CPU core count plus 1 (or RAM limit), Emerge jobs set to half that number rounded up, both with a load average limit set to 1 more than the number of Make jobs specified in MAKEOPTS.

or

    MAKEOPTS set to some specific lower number, optionally with a load average limit set to the CPU core count (or RAM limit), and Emerge jobs not set (which will give you the default of 1 job).

### Notes

```sh
# define port_https = 8080
#
# table inet default {
#   set banned { flags dynamic, timeout; gc-interval 5m; size 65536; timeout 12h; type ipv4_addr; }
#
#   chain forward { type filter hook forward priority filter; policy drop; }
#   chain output { type filter hook output priority filter; policy accept; }
#
#   chain prerouting {
#     type nat hook prerouting priority dstnat
#     policy accept
#
#     tcp dport 443 redirect to $port_https
#   }
#   chain input {
#     type filter hook input priority filter
#     policy drop
#
#     ct state { established,related } accept
#     iif lo accept
#
#     ct state invalid drop
#     iif != lo ip daddr 127.0.0.0/8 drop
#     ip frag-off & 0x3fff != 0 drop
#     ip saddr @banned drop
#
#     icmp type echo-request limit rate 2/second burst 4 packets accept
#     icmp type { destination-unreachable,echo-reply,time-exceeded } accept
#
#     tcp dport 22 ct state new limit rate 2/minute burst 4 packets accept
#     tcp dport 22 ct state new add @banned { ip saddr } drop
#
#     tcp dport $port_https ct status dnat limit rate 32/second burst 64 packets accept
#   }
# }
```

```bash
DuckDNS_Token="token" acme.sh --dns dns_duckdns --domain '*.remote-4620.duckdns.org' --issue
cat \*.remote-4620.duckdns.org.key fullchain.cer > remote-4620.duckdns.org.pem

# placeholder values
export SPACESHIP_API_KEY='8azEY0VMllj859ZqepH7'
export SPACESHIP_API_SECRET='JkZcYYVvSgwSAOXugXrBZ38nbhcanwiZvYP1MtTu0erI32Vmdxtcxn0tTGGL7SGW'
export SPACESHIP_ROOT_DOMAIN='(Optional) <Manually specify the root domain if auto-detection fails>'

podman run --rm neilpang/acme.sh
./acme.sh --issue --dns dns_spaceship -d example.domain.com



git-crypt init
git-crypt export-key key.bin
gpg --pinentry-mode loopback --symmetric key.bin

gpg --pinentry-mode loopback -d key.bin.gpg > key.bin
git-crypt unlock key.bin
```

https://tonsky.me/blog/syntax-highlighting/

#### Setup Oracle VPS

- Create virtual network with default parameters.
- Create compute instance using default parameters, but changing the shape to ampere 4 cpu 24 gb mem and using ubuntu.
- Connect with the ssh key pair into the instance and change the ubuntu user password with:
```bash
sudo su
passwd ubuntu
```
- Open cloud shell connection on: Compute > <select instance> > OS Management > Console connection > Launch Cloud Shell connection and run:
```bash
sudo su
cd /boot/efi
wget https://boot.netboot.xyz/ipxe/netboot.xyz-arm64.efi
wget https://boot.netboot.xyz/ipxe/netboot.xyz-arm64.efi
```
- Reboot and press ESC repeatdly until the UEFI shell appear then choose Boot Maintenance Manager > Boot From File > search for the netboot file
- Choose Linux Network Installers > Alpine > Login as root with not password and setup environment:
```bash
echo 'auto eth0' > /etc/network/interfaces
echo 'iface eth0 inet dhcp' >> /etc/network/interfaces
/etc/init.d/networking restart
ping -c 3 gentoo.org
setup-sshd # type 'yes' to 'Allow root ssh login?'
passwd
```
- Login with ssh to root@<ip> and setup installation:
```bash
setup-apkrepos -1 && apk update
apk add curl dosfstools e2fsprogs tar util-linux xz
curl -Lfs -- https://raw.githubusercontent.com/pedro-pereira-dev/dotfiles/refs/heads/main/install-gentoo.sh |

sh -s -- --hostname gs-home --password root
sh -s -- --hostname gs-proxy --password root
```

[Source](https://gist.github.com/amishmm/e2dc93e65cf79116f2ef2d542f05e61b)
[authelia haproxy](https://gist.github.com/matejaputic/52a0716da980f992800ba53202274884)

```shell
# elevate to root
sudo -i
# prevent any snap installation
cat <<EOF > /etc/apt/preferences.d/nosnap.pref
Package: snapd
Pin: release a=*
Pin-Priority: -10
EOF
# update 
apt update
apt dist-upgrade -y
apt install lsof -y
# make snap disappear
snap remove --purge oracle-cloud-agent
snap remove --purge core18
snap remove --purge snapd
systemctl stop snapd
systemctl disable snapd.service snapd.socket
apt purge snapd -y
rm -rf /var/cache/snapd/ /var/lib/snapd/ /var/snap/ /snap/ /home/*/snap /root/snap
# reboot so latest kernel is used
reboot
# re-elevate to root
sudo -i
# do the cleanup
apt purge $(dpkg-query -Wf '${Package}\n' | grep header) $(apt list --installed | grep -oP "^linux.*\d\d\d\d-oracle" | grep -v "$(uname -r)") linux-modules-extra-$(uname -r) lxc* lxd* vim* -y
apt autoremove -y
apt autoclean -y
apt clean -y
rm -rf /var/log/* /var/lib/apt/lists/*
# check /dev/sda1, it should be small enough
df -h
# create the ramdisk (since i'm on the arm64 ampere A1 i have 24GB ram so put 4G there)
cd /
mount -t tmpfs -o size=4000m tmpfs mnt
tar --one-file-system -c . | tar -C /mnt -x
# switch the VFS
mount --make-private -o remount,rw /
mount --move dev mnt/dev
mount --move proc mnt/proc
mount --move run mnt/run
mount --move sys mnt/sys
# rewrite the fstab to pount to our ramdisk
sed -i '/^[^#]/d;' mnt/etc/fstab
echo 'tmpfs / tmpfs defaults 0 0' >> mnt/etc/fstab
# go into our ramdisk
cd mnt
mkdir old_root
mount --make-private /
unshare -m
pivot_root . old_root
# actually fix the env so shit work
chroot /mnt
# kill processes
pkill agetty
pkill dbus-daemon
pkill atd
pkill iscsid
pkill rpcbind
pkill -f unattended-upgrades
kill 1
# check if there is no stupid process still running
lsof /old_root
# prep our disk to be overwritten
umount -l /dev/sda1
# last sanity check
df -h
lsblk
# here we gooooo (flashing latest debian)
curl -L https://cloud.debian.org/images/cloud/trixie/latest/debian-13-generic-arm64.tar.xz | tar -OJxvf - disk.raw | dd of=/dev/sda bs=1M
# sync once it's done
sync
# now to reboot we need to use magic trick as reboot won't work under chroot
echo 1 > /proc/sys/kernel/sysrq
echo b > /proc/sysrq-trigger
```

```md
make opnsense work in virtualized proxmox oci
same mac address on the oci vnic and vmbridge of wan opnsense
on the network interface settings of the bridge in the proxmox host
auto vmbr1
iface vmbr1 inet manual
        bridge-ports enp1s0
        bridge-stp off
        bridge-fd 0
        post-up ip link set enp1s0 promisc on
        post-up bridge fdb flush dev vmbr1
```

{
  echo '# system'
  is_bios && echo "UUID=\"$(get_uuid "$_boot_dev")\" /boot ext4 defaults,noatime,nodev,nosuid 0 2"
  is_uefi && echo "UUID=\"$(get_uuid "$_boot_dev")\" /efi vfat defaults,noatime,nodev,noexec,nosuid,umask=0077 0 2"
  echo "UUID=\"$(get_uuid "$_root_dev")\" / ext4 defaults,noatime 0 1"
} >/mnt/etc/fstab

is_swap_enabled "$@" && {
  chroot /mnt /bin/bash -c "fallocate -l $_swap_size /swap" || exit 1
  chroot /mnt /bin/bash -c 'chmod 600 /swap'
  chroot /mnt /bin/bash -c 'mkswap /swap' || exit 1
  {
    echo '# base'
    echo '/swap none swap sw 0 0'
  } >>/mnt/etc/fstab
}


@reboot (sleep 60 && echo 0 > /sys/class/backlight/intel_backlight/brightness)

/etc/apt/
/etc/fstab
/etc/hosts
/etc/ssh/sshd_config
/etc/bin.d/*
crontab -e



arch: amd64
cores: 2
features: nesting=1,fuse=1
hostname: pve1-nas
memory: 2048
net0: name=eth0,bridge=vmbr0,gw=192.168.0.1,hwaddr=BC:24:11:48:20:D1,ip=192.168.0.30/24,type=veth
onboot: 1
ostype: debian
rootfs: data:vm-1030-disk-0,size=8G
snaptime: 1775596478
swap: 512
tags: nas;network
timezone: Europe/Lisbon
lxc.cgroup2.devices.allow: a
lxc.cap.drop:
lxc.cgroup2.devices.allow: b 8:* rwm
lxc.cgroup2.devices.allow: c 188:* rwm
lxc.cgroup2.devices.allow: c 189:* rwm
lxc.mount.entry: /dev/sda           dev/sda           none bind,optional,create=file
lxc.mount.entry: /dev/sda1          dev/sda1          none bind,optional,create=file
lxc.mount.entry: /dev/sdc           dev/sdc           none bind,optional,create=file
lxc.mount.entry: /dev/sdc1          dev/sdc1          none bind,optional,create=file
lxc.mount.entry: /dev/sdd           dev/sdd           none bind,optional,create=file
lxc.mount.entry: /dev/sdd1          dev/sdd1          none bind,optional,create=file
lxc.mount.entry: /dev/serial/by-id  dev/serial/by-id  none bind,optional,create=dir
lxc.mount.entry: /dev/ttyACM0       dev/ttyACM0       none bind,optional,create=file
lxc.mount.entry: /dev/ttyACM1       dev/ttyACM1       none bind,optional,create=file
lxc.mount.entry: /dev/ttyUSB0       dev/ttyUSB0       none bind,optional,create=file
lxc.mount.entry: /dev/ttyUSB1       dev/ttyUSB1       none bind,optional,create=file





nano /etc/systemd/system/nebula-sync.service

[Unit]
Description=Nebula Sync Service
After=network.target

[Service]
Type=simple
ExecStart=/usr/bin/nebula-sync run --env-file /root/nebula-sync/nebula-sync.env
Restart=on-failure
RestartSec=1min

[Install]
WantedBy=multi-user.target



nano nebula-sync/nebula-sync.env


PRIMARY=http://192.168.0.2|
REPLICAS=http://127.0.0.1|

CRON=* * * * *
FULL_SYNC=true
RUN_GRAVITY=true


nano $(which update)

nano nebula-sync/update.sh
#!/bin/bash
curl -Lfs "$(
  curl -s https://api.github.com/repos/lovelaze/nebula-sync/releases/latest |
    grep 'browser_download_url.*linux_amd64.tar.gz' | cut -d '"' -f 4
)" | tar -xzC /usr/bin/
chmod +x /usr/bin/nebula-sync


nano $(which update)
bash -c "/root/nebula-sync/update.sh"


### https://github.com/DoTheEvo/NAS-MergerFS-SnapRAID

UUID=785deb18-6f84-4821-b181-9a2b236a9919 /mnt/pool/fast-disk-01 ext4 defaults 0 0
UUID=d24931cf-c8c5-49c4-aa61-2d46699d5a05 /mnt/pool/slow-disk-01 ext4 defaults 0 0
UUID=4d3499fd-cec2-41bf-afd1-55ebd3f260b0 /mnt/pool/parity-disk-01 ext4 defaults 0 0

/mnt/pool/fast-disk-* /mnt/storage/fast mergerfs defaults 0 0
/mnt/pool/slow-disk-* /mnt/storage/slow mergerfs defaults 0 0
/mnt/pool/fast-disk-*:/mnt/pool/slow-disk-* /mnt/storage/data mergerfs defaults,category.create=ff 0 0

autosave 64

disk fast-disk-01 /mnt/pool/fast-disk-01
disk slow-disk-01 /mnt/pool/slow-disk-01

content /mnt/pool/.snapraid.content
content /mnt/pool/fast-disk-01/.snapraid.content
content /mnt/pool/slow-disk-01/.snapraid.content

parity /mnt/pool/parity-disk-01/.snapraid.parity





nano /etc/systemd/system/maintain-snapraid.service

[Unit]
Description=Mantains snapraid disk array

[Service]
Type=oneshot
ExecStart=/etc/bin.d/maintain-snapraid.sh





nano /etc/systemd/system/maintain-snapraid.timer

[Unit]
Description=Run snapraid disk array maintenance at a random time each day

[Timer]
OnCalendar=daily
RandomizedDelaySec=24h
Persistent=true

[Install]
WantedBy=timers.target



nano /etc/systemd/system/hdds-spindown-enabled.service

[Unit]
Description=Spindown all hdd devices after one hour idle
After=local-fs.target systemd-udev-settle.service

[Service]
Type=oneshot
ExecStart=/bin/sh -c 'for d in /sys/block/sd*; do [ -f "$d/queue/rotational" ] && [ "$(cat $d/queue/rotational)" -eq 1 ] && [ -b "/dev/$(basename $d)" ] && /usr/bin/hdparm -S 242 -B 127 /dev/$(basename $d) 2>/dev/null || true; done'

[Install]
WantedBy=multi-user.target



[Interface]
Address = 10.100.100.2/24
PrivateKey =
DNS = 10.100.100.1

[Peer]
AllowedIPs = 0.0.0.0/0
Endpoint = 79.72.63.98:61820
PublicKey =






ufw route allow in on podman0 out on eth0




auto vmbr0
iface vmbr0 inet manual
        address 10.11.12.1/24
        bridge-ports none
        bridge-stp off
        bridge-fd 0
        # Existing MASQUERADE rules
        post-up   echo 1 > /proc/sys/net/ipv4/ip_forward
        post-up   iptables -t nat -A POSTROUTING -s '10.11.12.0/24' -o enp0s6 -j MASQUERADE
        post-down iptables -t nat -D POSTROUTING -s '10.11.12.0/24' -o enp0s6 -j MASQUERADE

        # PORT FORWARDING: HTTP (80)
        post-up   iptables -t nat -A PREROUTING -i enp0s6 -p tcp --dport 80 -j DNAT --to-destination 10.11.12.10:80
        post-down iptables -t nat -D PREROUTING -i enp0s6 -p tcp --dport 80 -j DNAT --to-destination 10.11.12.10:80

        # PORT FORWARDING: DNS (53)
        post-up   iptables -t nat -A PREROUTING -i enp0s6 -p udp --dport 53 -j DNAT --to-destination 10.11.12.10:53
        post-down iptables -t nat -D PREROUTING -i enp0s6 -p udp --dport 53 -j DNAT --to-destination 10.11.12.10:53
