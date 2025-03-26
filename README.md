# dotfiles

My custom system dotfiles - *_WORK IN PROGRESS_*

## Linux

#### `gentoo-router` 

```bash
bash <(wget -qO- https://raw.githubusercontent.com/pedro-pereira-dev/dotfiles/refs/heads/main/gentoo-router/install.sh)
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
