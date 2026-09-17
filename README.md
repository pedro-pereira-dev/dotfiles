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

## Export macOS Settings

On a configured macOS host, export every readable defaults domain into the
chezmoi source:

```sh
~/.local/bin/export-macos-settings
```

The generated `.chezmoitemplates/install-tools/darwin/overwrite-settings` is replayed when
`overwriteSettings` is enabled for a Darwin host. Review it for private,
volatile, and machine-specific data before committing it.

## Dev Container

```sh
devcontainer up --workspace-folder . --dotfiles-repository https://github.com/pedro-pereira-dev/dotfiles
```
