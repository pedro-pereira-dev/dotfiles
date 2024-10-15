# dotfiles

This projects contains dotfiles to customize my systems as well as some useful bash scripts for daily driving my machines.

Currently only MacOs and Linux is supported.

## Bootstrap

To bootstrap the system clone this project using `yadm`:

```bash
yadm clone --bootstrap https://github.com/pedrojoaopereira/dotfiles
```


## Install

It is possible to install `gentoo` directly to a system and bootstrap it using a project named [gentoo-installer](https://github.com/pedrojoaopereira/gentoo-installer) in a debian base system. The `gentoo-installer` script can be executed with a `hostname` so that the system settings are configured from a template.


```bash
apt update
apt install curl -y
bash <(curl -s https://raw.githubusercontent.com/pedrojoaopereira/dotfiles/refs/heads/main/.install-gentoo.sh) gentoo-laptop-msi-es
```
