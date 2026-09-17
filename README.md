# Dotfiles

Chezmoi-managed setup for macOS and Debian systems.

## Bootstrap

With curl:

```sh
bash -c "$(curl -fsSL https://raw.githubusercontent.com/pedro-pereira-dev/dotfiles/main/bootstrap)"
```

## Update

```sh
dots update
```

## Dev Container

```sh
devcontainer up --workspace-folder . --dotfiles-repository https://github.com/pedro-pereira-dev/dotfiles
```
