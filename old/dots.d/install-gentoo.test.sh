#!/bin/sh
set -eou pipefail

_ARCH_NAME='' && [ "$#" -ge 1 ] && _ARCH_NAME="$1" && shift || exit 1 # amd64 or arm64
_BOOT_NAME='' && [ "$#" -ge 1 ] && _BOOT_NAME="$1" && shift || exit 1 # uefi or bios
get_arch() { ([ "$_ARCH_NAME" = amd64 ] && echo 'x86_64') || ([ "$_ARCH_NAME" = arm64 ] && echo 'aarch64') || exit 1; }
get_boot() { ([ "$_BOOT_NAME" = uefi ] && echo 'uefi') || ([ "$_BOOT_NAME" = bios ] && echo 'legacy') || exit 1; }
_ARCH=$(get_arch) && _BOOT=$(get_boot) || exit 1

_OVERLAY_NAME='headless.apkovl.tar.gz'
_ALPINE_OVERLAY="/tmp/$_OVERLAY_NAME"
[ ! -f "$_ALPINE_OVERLAY" ] &&
  echo 'Downloading alpine apk overlay:' &&
  ! curl -Lf --progress-bar -o "$_ALPINE_OVERLAY" \
    "https://github.com/macmpi/alpine-linux-headless-bootstrap/raw/refs/heads/main/$_OVERLAY_NAME" && exit 1 || true

_ALPINE_VERSION='/tmp/alpine-version.txt'
[ ! -f "$_ALPINE_VERSION" ] &&
  echo 'Fetching alpine version:' &&
  ! curl -Lfs "https://dl-cdn.alpinelinux.org/alpine/latest-stable/releases/$_ARCH/latest-releases.yaml" |
  grep -m 1 version | awk '{ print $NF }' >"$_ALPINE_VERSION" && rm -fr "$_ALPINE_VERSION" && exit 1 || true

_ALPINE_ISO="/tmp/alpine-$_ARCH.iso"
[ ! -f "$_ALPINE_ISO" ] &&
  echo "Downloading alpine-standard-$_ARCH-v$(cat "$_ALPINE_VERSION"):" &&
  ! curl -Lf --progress-bar -o "$_ALPINE_ISO" \
    "https://dl-cdn.alpinelinux.org/alpine/latest-stable/releases/$_ARCH/alpine-standard-$(cat "$_ALPINE_VERSION")-$_ARCH.iso" && exit 1 || true

_ALPINE_ISO_CUSTOM="/tmp/custom-alpine-$_ARCH.iso"
[ ! -f "$_ALPINE_ISO_CUSTOM" ] &&
  ! xorriso \
    -indev "$_ALPINE_ISO" \
    -outdev "$_ALPINE_ISO_CUSTOM" \
    -map "$_ALPINE_OVERLAY" \
    "/$_OVERLAY_NAME" \
    -boot_image any replay && exit 1 || true

_CONTAINER_NAME='install-gento-test'
[ "$_ARCH_NAME" = amd64 ] && _CONTAINER_IMAGE='docker.io/qemux/qemu'
[ "$_ARCH_NAME" = arm64 ] && _CONTAINER_IMAGE='docker.io/qemux/qemu-arm'
_STORAGE="/tmp/$_CONTAINER_NAME"
rm -fr "$_STORAGE" && mkdir -p "$_STORAGE"
! podman run --replace -d --name "$_CONTAINER_NAME" \
  --device=/dev/kvm \
  -e BOOT_MODE="$_BOOT" \
  -p 2222:22 \
  -p 8006:8006 \
  -v "$_ALPINE_ISO_CUSTOM:/boot.iso" \
  -v "$_STORAGE:/storage" \
  "$_CONTAINER_IMAGE" && exit 1 || true

printf 'Attempting to connect to target..'
while ! ssh -o BatchMode=yes -o ConnectTimeout=1 -p 2222 -q root@localhost exit; do
  printf '.'
  sleep 1
done
echo ''

run_on_target() { ssh -o BatchMode=yes -p 2222 -q root@localhost "$@"; }
run_on_target 'setup-apkrepos -1 && apk update'
run_on_target 'apk add curl dosfstools e2fsprogs tar util-linux xz'
# run_on_target "\
#   curl -Lfs -o dots https://raw.githubusercontent.com/pedro-pereira-dev/dotfiles/refs/heads/main/dots && \
#   sh dots install --hostname gv-test --password root"

# run_on_target 'setup-apkrepos -1'
# run_on_target 'apk update'
# run_on_target 'apk add curl dosfstools e2fsprogs parted tar util-linux xz'
# run_on_target 'curl -Lfs https://raw.githubusercontent.com/pedro-pereira-dev/dotfiles/refs/heads/main/dots | sh -s -- install --password root --hostname gentoo-test'

# podman rm -f "$_CONTAINER_NAME"
