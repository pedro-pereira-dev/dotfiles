# dotfiles

Declarative configuration for my systems: NixOS hosts, a nix-darwin Mac and home-manager for user files.

## Bootstrap

```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/pedro-pereira-dev/dotfiles/main/bootstrap)"
```

`bootstrap` downloads the repository tarball into a temporary directory and runs `dots <command>`.
Managed hosts have a `dots` command that runs `~/workspace/personal/dotfiles/dots` when cloned, otherwise `bootstrap`.

## Usage

```
dots pull                                   git pull the clone, or download the tarball to a temp dir
dots sync [--host NAME] [--target U@HOST]   switch the local or remote host to its configuration
dots update [sync options]                  pull, then sync with the pulled code
dots install --self|--target U@HOST [--host NAME]
```

`install` runs nixos-anywhere and erases the target disk according to the host's `<hostname>-disko.nix`.

## Hosts

- `bra-m0234` – MacBook Pro M2, work, nix-darwin + Homebrew
- `nixos-desktop` – AMD workstation
- `nixos-dell` – Intel laptop

## NixOS user passwords

Root is a tmpfs; password hashes live in `/persistent/secrets/<user>`:

```bash
user=chuck
mkdir -p /persistent/secrets && chmod 700 /persistent/secrets
mkpasswd -m yescrypt > "/persistent/secrets/$user"
chmod 600 "/persistent/secrets/$user"
```

`~/workspace` is persisted in `/persistent`.

## Layout

- `bootstrap`, `dots` – entry points
- `dots.d/lib/` – shell functions used by `dots`
- `hosts/<name>.d/` – per-host configuration
- `flakes.d/profiles/` – shared imports organized by system role
- `flakes.d/lib/` – reusable Nix functions
- `flakes.d/modules/` – system modules and home configuration files
- `bin/` – macOS maintenance scripts
