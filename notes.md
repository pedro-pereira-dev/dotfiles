### Set up hosts

https://pve.proxmox.com/wiki/Install_Proxmox_VE_on_Debian_13_Trixie#Ensure_Hostname_Resolves_to_Hosts_IP_Address

### Add proxmox VE

https://pve.proxmox.com/wiki/Install_Proxmox_VE_on_Debian_13_Trixie#Add_Proxmox_VE_Repository

### Instal proxmox-backup-client

```bash
apt update
apt install arch-install-scripts proxmox-backup-client
```

### Set environment variables

```bash
mkdir /mnt
mount /ROOT_DISK /mnt

rm -fr /mnt/etc/pve # ???
mkdir -p /mnt/etc/pve # ???

export PBS_PASSWORD="your-password"
export PBS_REPOSITORY="root@pam!pve1-token-pve2-pbs@192.168.0.8:baks"

proxmox-backup-client snapshot list --ns local/pve1-baks-remote
proxmox-backup-client restore host/pve1/2026-03-30T16:04:26Z root.pxar /mnt --ns local/pve1-baks-remote

arch-chroot /mnt
mount /BOOT_DISK /boot/efi

update-grub
update-initramfs -u
proxmox-boot-tool reinit
exit
umount -R /mnt
reboot
```

### Finish but verifying API keys, backup jobs and storage connections
