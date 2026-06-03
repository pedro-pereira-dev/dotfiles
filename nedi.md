# `nedi`

## Details

- Site: Personal
- OS: Debian 13 / Proxmox 9
- IPv4: `192.168.0.5`

```
root@nedi:~# lsblk -o NAME,FSTYPE,UUID,SIZE,FSAVAIL,MOUNTPOINTS
NAME        FSTYPE      UUID                                     SIZE FSAVAIL MOUNTPOINTS
sda                                                            223.6G
├─sda1      vfat        DFE9-64DC                                 63M   56.5M /boot/efi
└─sda2      LVM2_member 16J7Dc-UyEk-5vVZ-3t8I-32mj-gco6-VuzYxP 223.5G
  ├─vg-swap swap        f2d6d049-19f7-4715-a74e-e5b8a0931d3d       1G         [SWAP]
  └─vg-root ext4        1044ac8d-4d16-4845-9ac7-db5ab13cdd9f       8G    6.4G /
sdb                                                            223.6G
└─sdb1      ext4        b21580d7-e52a-4ac2-bb6d-ca8347a33450   223.6G
sdc                                                            931.5G
└─sdc1      ext4        c7fb6d97-8e2b-4fe7-a454-34ba33ad2ae2   931.5G
sdd                                                            931.5G
└─sdd1      ext4        b9fc0940-b26e-4990-90cd-e7b37ddf3884   931.5G
```

Ports opened:

```
root@nedi:~# ufw status verbose
Status: active
Logging: on (low)
Default: deny (incoming), allow (outgoing), disabled (routed)
New profiles: skip

To                         Action      From
--                         ------      ----
22/tcp                     ALLOW IN    10.0.0.0/8
22/tcp                     ALLOW IN    172.16.0.0/12
22/tcp                     ALLOW IN    192.168.0.0/16
8006/tcp                   ALLOW IN    10.0.0.0/8
8006/tcp                   ALLOW IN    172.16.0.0/12
8006/tcp                   ALLOW IN    192.168.0.0/16
```

## Initial system setup

```bash

# downloads netboot
apt install -y curl
mkdir -p /boot/efi/EFI/netboot
curl -Lfs https://boot.netboot.xyz/ipxe/netboot.xyz.efi -o /boot/efi/EFI/netboot/netboot.xyz.efi

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

# sets up fstab
cat << 'EOF' > /etc/fstab
UUID=DFE9-64DC                              /boot/efi   vfat    defaults,noatime,nodev,noexec,nosuid,umask=0077 0 2
UUID=f2d6d049-19f7-4715-a74e-e5b8a0931d3d   none        swap    sw 0 0
UUID=1044ac8d-4d16-4845-9ac7-db5ab13cdd9f   /           ext4    defaults,errors=remount-ro 0 1
EOF

# disables ipv6 networking
cat << 'EOF' > /etc/sysctl.d/99-disable-ipv6.conf
net.ipv6.conf.all.disable_ipv6 = 1
net.ipv6.conf.default.disable_ipv6 = 1
net.ipv6.conf.lo.disable_ipv6 = 1
EOF
sysctl --system >/dev/null 2>&1

# sets up grub
sed -i 's/^GRUB_TIMEOUT=.*/GRUB_TIMEOUT=0/' /etc/default/grub
sed -i 's/GRUB_CMDLINE_LINUX_DEFAULT="\(.*\)"/GRUB_CMDLINE_LINUX_DEFAULT="\1 ipv6.disable=1"/' /etc/default/grub
update-grub

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
URIs: http://download.proxmox.com/debian/pve
Suites: trixie
Components: pve-no-subscription
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

# sets up proxmox kernel
apt install -y proxmox-default-kernel
systemctl reboot

# sets up proxmox dependencies
apt install -y chrony open-iscsi postfix proxmox-ve
# choose local only and leave the system name as is
apt remove -y linux-image-amd64 'linux-image-6.12*'
update-grub
apt remove -y os-prober

# sets up storage
lvcreate -l 100%FREE --thinpool data vg

# runs proxmox helper scripts
apt install -y curl
bash -c "$(curl -fsSL https://raw.githubusercontent.com/community-scripts/ProxmoxVE/main/tools/pve/microcode.sh)"
bash -c "$(curl -fsSL https://raw.githubusercontent.com/community-scripts/ProxmoxVE/main/tools/pve/post-pve-install.sh)"
bash -c "$(curl -fsSL https://raw.githubusercontent.com/community-scripts/ProxmoxVE/main/tools/pve/kernel-clean.sh)"
bash -c "$(curl -fsSL https://raw.githubusercontent.com/community-scripts/ProxmoxVE/main/tools/pve/scaling-governor.sh)"

# sets up autoaspm
cat << 'EOF' > /usr/bin/autoaspm
#!/usr/bin/env python3
#
# Original bash script by Luis R. Rodriguez
# Re-written in Python by z8
# Re-re-written to patch supported devices automatically by notthebee
#
import re
import subprocess
import os
import platform
from enum import Enum
#
class ASPM(Enum):
    DISABLED = 0b00
    L0s = 0b01
    L1 = 0b10
    L0sL1 = 0b11
#
#
def run_prerequisites():
    if platform.system() != "Linux":
        raise OSError("This script only runs on Linux-based systems")
    if not os.environ.get("SUDO_UID") and os.geteuid() != 0:
        raise PermissionError("This script needs root privileges to run")
    lspci_detected = subprocess.run(["which", "lspci"], stdout = subprocess.DEVNULL, stderr = subprocess.DEVNULL)
    if lspci_detected.returncode > 0:
        raise Exception("lspci not detected. Please install pciutils")
    lspci_detected = subprocess.run(["which", "setpci"], stdout = subprocess.DEVNULL, stderr = subprocess.DEVNULL)
    if lspci_detected.returncode > 0:
        raise Exception("setpci not detected. Please install pciutils")
#
#
def get_device_name(addr):
    p = subprocess.Popen([
        "lspci",
        "-s",
        addr,
    ], stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    return p.communicate()[0].splitlines()[0].decode()
#
def read_all_bytes(device):
    all_bytes = bytearray()
    device_name = get_device_name(device)
    p = subprocess.Popen([
        "lspci",
        "-s",
        device,
        "-xxx"
    ], stdout= subprocess.PIPE, stderr=subprocess.PIPE)
    ret = p.communicate()
    ret = ret[0].decode()
    for line in ret.splitlines():
        if not device_name in line and ": " in line:
            all_bytes.extend(bytearray.fromhex(line.split(": ")[1]))
    if len(all_bytes) < 256:
        exit()
    return all_bytes
#
def find_byte_to_patch(bytes, pos):
    pos = bytes[pos]
    if bytes[pos] != 0x10:
        pos += 0x1
        return find_byte_to_patch(bytes, pos)
    else:
        pos += 0x10
        return pos
#
def patch_byte(device, position, value):
    subprocess.Popen([
        "setpci",
        "-s",
        device,
        f"{hex(position)}.B={hex(value)}"
    ]).communicate()
#
def patch_device(addr, aspm_value):
    endpoint_bytes = read_all_bytes(addr)
    byte_position_to_patch = find_byte_to_patch(endpoint_bytes, 0x34)
    if int(endpoint_bytes[byte_position_to_patch]) & 0b11 != aspm_value.value:
        patched_byte = int(endpoint_bytes[byte_position_to_patch])
        patched_byte = patched_byte >> 2
        patched_byte = patched_byte << 2
        patched_byte = patched_byte | aspm_value.value
#
        patch_byte(addr, byte_position_to_patch, patched_byte)
        print(f"{addr}: Enabled ASPM {aspm_value.name}")
    else:
        print(f"{addr}: Already has ASPM {aspm_value.name} enabled")
#
#
def list_supported_devices():
    pcie_addr_regex = r"([0-9a-f]{2}:[0-9a-f]{2}\.[0-9a-f])"
    lspci = subprocess.run("lspci -vv", shell=True, capture_output=True).stdout
    lspci_arr = re.split(pcie_addr_regex, str(lspci))[1:]
    lspci_arr = [ x+y for x,y in zip(lspci_arr[0::2], lspci_arr[1::2]) ]
#
    aspm_devices = {}
    for dev in lspci_arr:
        device_addr = re.findall(pcie_addr_regex, dev)[0]
        if "ASPM" not in dev or "ASPM not supported" in dev:
            continue
        aspm_support = re.findall(r"ASPM (L[L0-1s ]*),", dev)
        if aspm_support:
            aspm_devices.update({device_addr: ASPM[aspm_support[0].replace(" ", "")]})
    return aspm_devices
#
#
def main():
    run_prerequisites()
    for device, aspm_mode in list_supported_devices().items():
        patch_device(device, aspm_mode)
#
if __name__ == "__main__":
    main()
#
EOF
chmod +x /usr/bin/autoaspm
autoaspm
(crontab -l 2>/dev/null; echo "@reboot (sleep 60 && autoaspm)") | crontab -

# sets up backup-host-to
cat << 'EOF' > /usr/bin/backup-host-to
#!/bin/bash
#
! /usr/sbin/pvesm status --storage "$1" >/dev/null 2>&1 &&
  echo "Storage ($1) not found, skipping backup" &&
  exit 1
#
PBS_DATASTORE=$(sed -n "/pbs: $1/,/^$/p" /etc/pve/storage.cfg | sed -n "s/\s.*datastore //p")
test -z "$PBS_DATASTORE" &&
  echo "Storage ($1) configuration PBS_DATASTORE, skipping backup" &&
  exit 1
#
PBS_NAMESPACE=$(sed -n "/pbs: $1/,/^$/p" /etc/pve/storage.cfg | sed -n "s/\s.*namespace //p")
test -z "$PBS_DATASTORE" &&
  echo "Storage ($1) configuration PBS_NAMESPACE, skipping backup" &&
  exit 1
#
PBS_SERVER=$(sed -n "/pbs: $1/,/^$/p" /etc/pve/storage.cfg | sed -n "s/\s.*server //p")
test -z "$PBS_DATASTORE" &&
  echo "Storage ($1) configuration PBS_SERVER, skipping backup" &&
  exit 1
#
PBS_USERNAME=$(sed -n "/pbs: $1/,/^$/p" /etc/pve/storage.cfg | sed -n "s/\s.*username //p")
test -z "$PBS_DATASTORE" &&
  echo "Storage ($1) configuration PBS_USERNAME, skipping backup" &&
  exit 1
#
PBS_FINGERPRINT=$(sed -n "/pbs: $1/,/^$/p" /etc/pve/storage.cfg | sed -n "s/\s.*fingerprint //p")
test -z "$PBS_DATASTORE" &&
  echo "Storage ($1) configuration PBS_FINGERPRINT, skipping backup" &&
  exit 1
#
PBS_PASSWORD=$(cat "/etc/pve/priv/storage/$1.pw")
test -z "$PBS_DATASTORE" &&
  echo "Storage ($1) configuration PBS_PASSWORD, skipping backup" &&
  exit 1
#
PBS_REPOSITORY="$PBS_USERNAME@$PBS_SERVER:$PBS_DATASTORE"
test -z "$PBS_DATASTORE" &&
  echo "Storage ($1) configuration PBS_REPOSITORY, skipping backup" &&
  exit 1
#
export PBS_FINGERPRINT PBS_PASSWORD PBS_REPOSITORY
/usr/bin/proxmox-backup-client backup root.pxar:/ --ns "$PBS_NAMESPACE"
EOF
chmod +x /usr/bin/backup-host-to
(crontab -l 2>/dev/null; echo "0 2 * * * backup-host-to nedi-pbs-local") | crontab -

# sets up nfs shares
apt install -y nfs-common
mkdir -p /mnt/shared/nfs
cat << 'EOF' > /usr/bin/mount-nfs-share
#!/bin/sh
NFS_SERVER="192.168.0.4"
NFS_PATH="/data/share"
NFS_MOUNT="/mnt/shared/nfs"
if ping -c 1 -W 1 "$NFS_SERVER" >/dev/null 2>&1; then
  # NFS is up
  if ! mountpoint -q "$NFS_MOUNT" 2>/dev/null; then
    mount -t nfs "$NFS_SERVER:$NFS_PATH" "$NFS_MOUNT" 2>/dev/null
  else
    if ! timeout 5 stat "$NFS_MOUNT" >/dev/null 2>&1; then
      umount -l "$NFS_MOUNT" 2>/dev/null
      mount -t nfs "$NFS_SERVER:$NFS_PATH" "$NFS_MOUNT" 2>/dev/null
    fi
  fi
else
  # NFS is down
  if mountpoint -q "$NFS_MOUNT" 2>/dev/null; then
    umount -l "$NFS_MOUNT" 2>/dev/null
  fi
fi
EOF
chmod +x /usr/bin/mount-nfs-share
(crontab -l 2>/dev/null; echo "* * * * * mount-nfs-share") | crontab -
(crontab -l 2>/dev/null; echo "* * * * * ! mountpoint -q /mnt/pve/nedi-nas && umount -fl /mnt/pve/nedi-nas") | crontab -

# sets up firewall
apt install -y ufw
ufw default allow outgoing
ufw default deny incoming
# SSH
ufw allow from 10.0.0.0/8 to any port 22 proto tcp
ufw allow from 172.16.0.0/12 to any port 22 proto tcp
ufw allow from 192.168.0.0/16 to any port 22 proto tcp
# Proxmox
ufw allow from 10.0.0.0/8 to any port 8006 proto tcp
ufw allow from 172.16.0.0/12 to any port 8006 proto tcp
ufw allow from 192.168.0.0/16 to any port 8006 proto tcp
ufw enable

```
