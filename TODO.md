# Repository Cleanup TODO

## Confirmed Cleanup

- [ ] Remove the unused `_log_message` assignment from `.chezmoitemplates/shared/add_logging:12`.
- [ ] Decide whether `.local/bin/update` should exist on Linux. Its rendered script only prints a blank line, defines logging helpers, and exits because all operations are Darwin-only.

## Host Configuration

- [ ] Decide whether to enable or remove the dormant `installChezmoi` configuration in `.chezmoitemplates/linux/configure`. No current host defines `installChezmoi`, so the operational body is never rendered.
- [ ] Review `installXcode: true` in `.chezmoidata/bra-m0234.yaml`. It is redundant because the selected Homebrew installation path already installs Xcode.
- [ ] Review `installHomebrew: true` in `.chezmoidata/bra-m0234.yaml`. It is redundant because `useBash: true` and the `homebrew` key already enable Homebrew management.
- [ ] Confirm whether `.chezmoidata/lima-temp.yaml` is still needed. Host data is matched by exact hostname, and the current machine is `lima-default`.

## Commands

- [ ] Confirm whether `dot_local/bin/executable_update.tmpl` is still intended as a public command. It has no repository callers, is undocumented, and overlaps with `dots update`.
- [ ] Confirm whether the default/list mode in `dot_local/bin/executable_mybrew.tmpl` is intentionally user-facing. No internal caller uses it.
- [ ] Decide whether unknown `mybrew` arguments should show the package list or fail with a usage error.

## Managed Files

- [ ] Confirm whether `AGENTS.md` should be installed as `$HOME/AGENTS.md`. Add it to `.chezmoiignore` if it is only intended as repository guidance.

## Verified Live Flags

The audit found no definitely dead command-line flags:

- `mysoftwareupdate --check` is used by the bootstrap/configure and update paths.
- `mysoftwareupdate --force` is used by the bootstrap/configure path.
- Interactive `mysoftwareupdate` is used by the update script.
- `dots bootstrap` is used by `bootstrap`.
- `dots update` is documented and used by local bootstrap.
- `mybrew check` and `mybrew update` both have internal callers.
