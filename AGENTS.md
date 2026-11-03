# Repository conventions

Declarative configuration for NixOS hosts, a nix-darwin Mac, and user files managed with Home Manager.

## Layout

- `dots` and `dots.d/` — command entry point, workflows, and shared shell helpers.
- `hosts/<name>.d/` — host-specific Nix configuration and related files.
- `flakes.d/profiles/` — shared module sets organized by system role.
- `flakes.d/modules/` — reusable NixOS modules and home configuration.
- `flakes.d/lib/` — reusable Nix functions.
- `bin/` — macOS maintenance commands.

## Commands

- `dots bootstrap --self|--target U@HOST [--host NAME]` installs NixOS with `nixos-anywhere`.
- `dots setup --self|--target U@HOST [--host NAME]` switches to the selected host configuration.
- `dots pull --self|--target U@HOST [--force]` clones or fast-forwards the workspace.
- `dots update --self|--target U@HOST [--host NAME]` pulls, then runs setup.
- `nix fmt` formats the flake using its configured formatter.
- `nix flake check` evaluates the flake checks.

## Configuration conventions

- Put reusable NixOS defaults in modules under `flakes.d/modules/` and import them through a profile when shared by that role.
- Keep hardware, disk layout, and host-specific package or service choices in `hosts/<name>.d/`.
- nix-darwin hosts import their own applicable modules; do not import NixOS-only modules into them.
- Keep shell workflows in `dots.d/` and macOS maintenance commands in `bin/`.
- Nix evaluates the Git source tree: add new files to Git before running flake evaluation that imports them.
