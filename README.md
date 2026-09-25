# dotfiles

## Bootstrap

On a fresh machine (no git required):

```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/pedro-pereira-dev/dotfiles/main/bootstrap)"
```

`bootstrap` downloads the repository tarball into `~/workspace/personal/dotfiles` and runs `dots update`.

## Usage

```
dots pull     # run the host's dots_pull (e.g. install tooling, clone/sync the repo)
dots sync     # run the host's dots_sync (e.g. link files, prune stale links)
dots update   # pull, then re-run dots so sync uses the freshly pulled code
```

`dots` expects the repository at `~/workspace/personal/dotfiles`. Once cloned, the local repository is forced to match `origin/$DOTFILES_BRANCH` on every pull.

## Adding a host

Create `hosts/<hostname -s>.sh` defining `dots_pull` and `dots_sync`. Host-specific files go in `hosts/<hostname -s>.d/`. `hosts/example.sh` is a minimal template for a tarball-only host. Unknown hosts fail.

## Layout

- `bootstrap`, `dots` – entry points
- `bin/` – executables linked into `~/.local/bin`
- `lib/` – function libraries sourced by `dots`
- `hosts/` – per-host configuration
- `shared/` – files linked on multiple hosts
