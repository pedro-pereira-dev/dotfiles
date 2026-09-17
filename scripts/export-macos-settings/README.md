# Export macOS Settings

On a configured macOS host, run the repository utility to write readable
system preference defaults and current-host defaults to
`/tmp/macos-settings.txt`. Preferences belonging to third-party applications
are not included.

```sh
./scripts/export-macos-settings/export
```

Review the temporary output for private and machine-specific data before
sharing it.
