# macOS Settings Workflow

This utility captures Apple preferences, compares snapshots, and interactively
updates the repository's desired macOS settings. Run every command from any
directory; the scripts locate the repository from their own paths.

## Capture

On macOS, capture `NSGlobalDomain` and every discovered `com.apple.*` domain in
both the normal `defaults` and `current-host` scopes:

```sh
./scripts/macos-settings/capture
```

Snapshots are deterministic, typed JSON files under `snapshots/`, named with a
sortable UTC timestamp such as `20260917T163157.123456Z.json`. Values are read
through XML plist exports, so booleans, numbers, strings, arrays, dictionaries,
binary data, and dates retain their types. Binary data and dates use tagged
JSON objects. Metadata records UTC capture time, macOS product and build
versions, and architecture.

Snapshots are raw and unfiltered. They persist locally for later comparisons
but are ignored by Git. Capture only creates its snapshot and never writes
macOS preferences.

## Compare

With no references, `diff` compares the two newest snapshots:

```sh
./scripts/macos-settings/diff
```

Pass exactly two references to choose the old and new snapshots. A reference
may be a path, a filename, or a timestamp without `.json`:

```sh
./scripts/macos-settings/diff 20260916T120000.000000Z 20260917T163157.123456Z
```

Output identifies added, removed, and changed keys by scope, domain, key, and
type, followed by pretty JSON old/new values. Differences do not cause a
nonzero exit. Missing snapshots and invalid usage do.

`filters.json` suppresses volatile key globs, exact settings, and tagged binary
or date values by default. It never affects captured data. Use `--all` before
or after the references to bypass filtering:

```sh
./scripts/macos-settings/diff --all
```

## Adopt

`adopt` uses the same latest-two default, explicit reference forms, filtering,
and `--all` option:

```sh
./scripts/macos-settings/adopt
./scripts/macos-settings/adopt --all OLD NEW
```

For each difference it can adopt the latest state/value, track a deletion,
remove the key from desired state, skip it, or add its exact scope/domain/key
to `filters.json`. Choices are accumulated before files are replaced
atomically. Cancellation before completion leaves them unwritten.

Adoption only updates `.chezmoidata/macos-settings.yaml`; it never runs
`defaults write` or otherwise changes the system. The emitted stdlib-only YAML
contains deterministic records under `macosSettings`, with JSON values inline.
Generic defaults rendering supports booleans, integers, floats, strings, and
arrays containing only those scalar types. Binary data, dates, dictionaries,
nested arrays, and null cannot be adopted as values; deletions can still be
tracked.
