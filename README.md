# dotfiles

My custom system dotfiles - *_WORK IN PROGRESS_*

## Default

```bash
bash <(wget -qO- https://raw.githubusercontent.com/pedro-pereira-dev/dotfiles/refs/heads/main/bootstrapper/bootstrap-dotfiles) <hostname>
```

## Linux

### gl-dell

```bash
bash <(wget -qO- https://raw.githubusercontent.com/pedro-pereira-dev/gentoo-installer/refs/heads/main/install.sh) \
  --hostname 'gl-dell' --username 'chuck'                                                                         \
  --device 'nvme0n1' --device-separator 'p'                                                                       \
  --efi-size '+1G' --swap-size '+8G' --root-size ' '                                                              \
  --timezone 'Europe/Lisbon' --keymap 'pt-latin9'

chroot /mnt/gentoo /bin/bash <<EOF
env-update && source /etc/profile && export PS1="(chroot) \${PS1}"
bash <(wget -qO- https://raw.githubusercontent.com/pedro-pereira-dev/dotfiles/refs/heads/main/bootstrapper/bootstrap-dotfiles) --unsupervised gl-dell
EOF
```

### gl-red

```bash
bash <(wget -qO- https://raw.githubusercontent.com/pedro-pereira-dev/gentoo-installer/refs/heads/main/install.sh) \
  --hostname 'gl-red' --username 'chuck'                                                                          \
  --device 'nvme0n1' --device-separator 'p'                                                                       \
  --efi-size '+1G' --swap-size '+32G' --root-size ' '                                                             \
  --timezone 'Europe/Lisbon' --keymap 'pt-latin9'

chroot /mnt/gentoo /bin/bash <<EOF
env-update && source /etc/profile && export PS1="(chroot) \${PS1}"
bash <(wget -qO- https://raw.githubusercontent.com/pedro-pereira-dev/dotfiles/refs/heads/main/bootstrapper/bootstrap-dotfiles) --unsupervised gl-red
EOF
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
