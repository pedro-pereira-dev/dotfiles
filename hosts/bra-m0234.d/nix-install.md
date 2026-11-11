# macOS Nix installation

On macOS, the sealed system volume is read-only and `/nix` may only be a synthetic,
empty directory. This host uses a sparse disk image stored in the user's home directory
and mounted at `/nix` to provide persistent, writable storage.

## Prepare `/nix`

Create a 128 GiB maximum HFS+ sparse bundle in the user's home directory and mount it
over the existing `/nix` mount point:

```sh
hdiutil create -size 128g -type SPARSEBUNDLE -fs HFS+ -volname nix "$HOME/nix.sparsebundle"
sudo hdiutil attach -owners on -mountpoint /nix "$HOME/nix.sparsebundle"
sudo chown "$(id -un):staff" /nix
```

The image is sparse and grows with its contents, up to 128 GiB. HFS+ supports ownership
and hard links. The image file is stored on the Data volume and is encrypted at rest by
FileVault.

Install an idempotent mount script at `/usr/local/sbin/mount-nix-image`:

```sh
#!/bin/sh
if /sbin/mount | /usr/bin/grep -q ' on /nix ('; then
  exit 0
fi
exec /usr/bin/hdiutil attach -quiet -owners on -mountpoint /nix /Users/pereiped/nix.sparsebundle
```

Make it executable with `sudo chmod 755 /usr/local/sbin/mount-nix-image`. Install
`/Library/LaunchDaemons/local.nix-image.plist` with this content:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>Label</key>
  <string>local.nix-image</string>
  <key>ProgramArguments</key>
  <array>
    <string>/usr/local/sbin/mount-nix-image</string>
  </array>
  <key>RunAtLoad</key>
  <true/>
</dict>
</plist>
```

Set its ownership and permissions, then load it:

```sh
sudo chown root:wheel /Library/LaunchDaemons/local.nix-image.plist
sudo chmod 644 /Library/LaunchDaemons/local.nix-image.plist
sudo launchctl bootstrap system /Library/LaunchDaemons/local.nix-image.plist
```

Verify the mount is writable as the user before continuing, for example with
`touch /nix/persistence-check`.

For the original `pereiped` machine, the LaunchDaemon and mount script were installed at
`/Library/LaunchDaemons/local.nix-image.plist` and
`/usr/local/sbin/mount-nix-image`, respectively. The mounted filesystem root was owned
by `pereiped:staff` with mode `755`, allowing direct writes before installing Nix.

Verify the image is mounted and writable before proceeding. A stale `/etc/fstab` entry
for `/nix` may exist; the old `nullfs` bind-mount entry does not work on macOS and is
unrelated to this image mount. On the original machine, SIP prevented removing that
entry from `/private/etc/fstab` even as root, so it was left inert.

## Install Nix

Download the Nix 2.24.10 installer for the machine architecture and disable volume
creation so the installer uses the existing `/nix` mount:

```sh
cd /tmp
ARCH="$(uname -m)"
if [ "$ARCH" = "arm64" ]; then NIX_ARCH="aarch64-darwin"; else NIX_ARCH="x86_64-darwin"; fi
curl -L "https://releases.nixos.org/nix/nix-2.24.10/nix-2.24.10-${NIX_ARCH}.tar.xz" -o nix.tar.xz
tar -xf nix.tar.xz
cd "nix-2.24.10-${NIX_ARCH}"
NIX_VOLUME_CREATE=0 ./install
```

The installer may report conflicts with existing files (for example, `/etc/bash`).
Resolve the prompts as appropriate for the machine, then verify the Nix installation
and that `/nix` remains mounted after restarting the Mac.

## Multi-user installation notes

The image mount must be ready before the Nix daemon starts. If using the multi-user
installer, it normally expects `/nix` to be owned by `root:wheel`; change ownership
before installation if needed. Ensure the daemon starts after the image mount, or
restart it once the mount is available.

The sparse bundle grows as data is written and has a 128 GiB maximum. Resize it while
detached with `hdiutil resize -size <newsize> ~/nix.sparsebundle`.

To verify automatic mounting, detach the image and restart the LaunchDaemon, then check
that `/nix` is mounted and the persistence-check file remains. On the original machine,
the daemon was tested with `sudo launchctl kickstart -k system/local.nix-image`.

To remove the setup, unload the LaunchDaemon, detach the image, remove its plist and
mount script, and then delete `~/nix.sparsebundle` if its contents are no longer needed.
