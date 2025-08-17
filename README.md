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

    MAKEOPTS equal to CPU core count plus 1 (or RAM limit), Emerge jobs set to half that number rounded up, both with a load average limit set to 1 more than the number of Make jobs specified in MAKEOPTS.

or

    MAKEOPTS set to some specific lower number, optionally with a load average limit set to the CPU core count (or RAM limit), and Emerge jobs not set (which will give you the default of 1 job).

### Notes

```bash
DuckDNS_Token="token" acme.sh --dns dns_duckdns --domain '*.remote-4620.duckdns.org' --issue
cat \*.remote-4620.duckdns.org.key fullchain.cer > remote-4620.duckdns.org.pem
```
