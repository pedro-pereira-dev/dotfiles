#!/bin/sh
set -eou pipefail

_OVERLAY_NAME='headless.apkovl.tar.gz'
_ALPINE_OVERLAY="/tmp/$_OVERLAY_NAME"
[ ! -f "$_ALPINE_OVERLAY" ] &&
  echo 'Downloading alpine apk overlay:' &&
  ! curl -Lf --progress-bar -o "$_ALPINE_OVERLAY" \
    "https://github.com/macmpi/alpine-linux-headless-bootstrap/raw/refs/heads/main/$_OVERLAY_NAME" && exit 1 || true

_ALPINE_VERSION='/tmp/alpine-version.txt'
[ ! -f "$_ALPINE_VERSION" ] &&
  echo 'Fetching alpine version:' &&
  ! curl -Lfs "https://dl-cdn.alpinelinux.org/alpine/latest-stable/releases/x86_64/latest-releases.yaml" |
  grep -m 1 version | awk '{ print $NF }' >"$_ALPINE_VERSION" && rm -fr "$_ALPINE_VERSION" && exit 1 || true

_ALPINE_ISO='/tmp/alpine-amd64.iso'
[ ! -f "$_ALPINE_ISO" ] &&
  echo "Downloading alpine-standard-amd64-v$(cat "$_ALPINE_VERSION"):" &&
  ! curl -Lf --progress-bar -o "$_ALPINE_ISO" \
    "https://dl-cdn.alpinelinux.org/alpine/latest-stable/releases/x86_64/alpine-standard-$(cat "$_ALPINE_VERSION")-x86_64.iso" && exit 1 || true

_ALPINE_ISO_CUSTOM='/tmp/custom-alpine-amd64.iso'
[ ! -f "$_ALPINE_ISO_CUSTOM" ] &&
  ! xorriso \
    -indev "$_ALPINE_ISO" \
    -outdev "$_ALPINE_ISO_CUSTOM" \
    -map "$_ALPINE_OVERLAY" \
    "/$_OVERLAY_NAME" \
    -boot_image any replay && exit 1 || true

_CONTAINER_NAME='install-gento-test-amd64'
_STORAGE="/tmp/$_CONTAINER_NAME"
rm -fr "$_STORAGE" && mkdir -p "$_STORAGE"
! podman run --replace --rm -d --name "$_CONTAINER_NAME" \
  --device=/dev/kvm \
  -e BOOT_MODE=uefi \
  -p 2222:22 \
  -p 8006:8006 \
  -v "$_ALPINE_ISO_CUSTOM:/boot.iso" \
  -v "$_STORAGE:/storage" \
  docker.io/qemux/qemu && exit 1 || true
# -e BOOT_MODE=legacy \

printf 'Attempting to connect to target..'
while ! ssh -o BatchMode=yes -o ConnectTimeout=1 -p 2222 -q root@localhost exit; do
  printf '.'
  sleep 1
done
echo ''

run_on_target() { ssh -o BatchMode=yes -p 2222 -q root@localhost "$@"; }

run_on_target ping -c 1 gentoo.org

run_on_target 'setup-apkrepos -1'
run_on_target 'apk update'
run_on_target 'apk add curl dosfstools e2fsprogs parted tar util-linux xz'
run_on_target 'curl -Lfs https://raw.githubusercontent.com/pedro-pereira-dev/dotfiles/refs/heads/main/dots | sh -s -- install --password root --hostname gentoo-test'

podman rm -f "$_CONTAINER_NAME"
