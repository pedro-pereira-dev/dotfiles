# dotfiles

My custom system dotfiles - *_WORK IN PROGRESS_*

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

```bash
DuckDNS_Token="token" acme.sh --dns dns_duckdns --domain '*.remote-4620.duckdns.org' --issue
cat \*.remote-4620.duckdns.org.key fullchain.cer > remote-4620.duckdns.org.pem
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
_TMP="$(mktemp)" && curl -Lfs -o "$_TMP" https://raw.githubusercontent.com/pedro-pereira-dev/dotfiles/refs/heads/main/install-gentoo.sh
sh "$_TMP" --hostname gv-test --password root
```

[Source](https://gist.github.com/amishmm/e2dc93e65cf79116f2ef2d542f05e61b)
