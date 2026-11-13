# dotfiles

Declarative configuration for my systems: NixOS hosts, a nix-darwin Mac and home-manager for user files.

## Scripts

```bash
curl -fsSL https://raw.githubusercontent.com/pedro-pereira-dev/dotfiles/main/dots | bash -s -- bootstrap --self
```

```bash
curl -fsSL https://raw.githubusercontent.com/pedro-pereira-dev/dotfiles/main/dots | bash -s -- setup --self
```

Without a clone in `~/workspace/personal/dotfiles` it downloads the latest tarball to `/tmp/dotfiles` and runs from there.
With a clone it runs the clone as is, so local changes are kept. Run `dots pull --self` to update it.

## Usage

```
dots bootstrap --self|--target U@HOST [--host NAME]   install NixOS with nixos-anywhere
dots setup     --self|--target U@HOST [--host NAME]   switch to the host configuration

dots pull      --self|--target U@HOST [--force]       clone or fast-forward the workspace
dots update    --self|--target U@HOST [--host NAME]   pull, then setup with the pulled code
```

## NixOS user passwords

Root is a tmpfs; password hashes live in `/persistent/secrets/<user>`:

```bash
user=chuck
mkdir -p /persistent/secrets && chmod 700 /persistent/secrets
mkpasswd -m yescrypt > "/persistent/secrets/$user"
chmod 600 "/persistent/secrets/$user"
```

## Layout

- `dots` – entry point
- `dots.d/lib/` – shell functions used by `dots`
- `hosts/<name>.d/` – per-host configuration
- `flakes.d/profiles/` – shared imports organized by system role
- `flakes.d/lib/` – reusable Nix functions
- `flakes.d/modules/` – system modules and home configuration files
- `bin/` – macOS maintenance scripts


```bash
nix --extra-experimental-features 'flakes nix-command' flake update --update-input nixpkgs
```
