#!/bin/sh
set -eou pipefail

create_custom_iso() {
  _ARCH=$1

  [ "$_ARCH" = amd64 ] && _ALPINE_ARCH=x86_64
  [ "$_ARCH" = arm64 ] && _ALPINE_ARCH=aarch64

  [ ! -f "/tmp/alpine-version-$_ARCH.txt" ] &&
    curl -Lfs "https://dl-cdn.alpinelinux.org/alpine/latest-stable/releases/$_ALPINE_ARCH/latest-releases.yaml" |
    grep -m 1 version | awk '{ print $NF }' >"/tmp/alpine-version-$_ARCH.txt"

  [ ! -f "/tmp/alpine-$_ARCH.iso" ] &&
    echo "Downloading alpine ($_ARCH) iso:" &&
    curl -Lf# -o "/tmp/alpine-$_ARCH.iso" \
      "https://dl-cdn.alpinelinux.org/alpine/latest-stable/releases/$_ALPINE_ARCH/alpine-standard-$(cat "/tmp/alpine-version-$_ARCH.txt")-$_ALPINE_ARCH.iso"

  [ ! -f "/tmp/custom-alpine-$_ARCH.iso" ] &&
    podman run --rm \
      -v "/tmp/alpine-$_ARCH.iso":"/tmp/alpine-$_ARCH.iso":ro \
      -v /tmp/alpine-overlay.apkvol:/tmp/alpine-overlay.apkvol:ro \
      -v /tmp:/workspace \
      docker.io/alpine \
      sh -c "\
        apk add --no-cache xorriso && \
        xorriso \
        -indev /tmp/alpine-$_ARCH.iso \
        -outdev /workspace/custom-alpine-$_ARCH.iso \
        -map /tmp/alpine-overlay.apkvol /headless.apkovl.tar.gz \
        -boot_image any replay"
}

create_container() {
  _ARCH=$1 && _BOOT_MODE=$2

  create_custom_iso "$_ARCH"
  [ "$_ARCH" = amd64 ] && _ISO=/tmp/custom-alpine-amd64.iso && _CONTAINER_IMAGE=docker.io/qemux/qemu
  [ "$_ARCH" = arm64 ] && _ISO=/tmp/custom-alpine-arm64.iso && _CONTAINER_IMAGE=docker.io/qemux/qemu-arm

  podman run -d \
    --name dots-test --replace \
    --device=/dev/kvm \
    -e BOOT_MODE="$_BOOT_MODE" \
    -e CPU_CORES=$(($(nproc) - 1)) \
    -e DISK_SIZE=8G \
    -e RAM_SIZE=$((($(free -g | awk '/Mem:/ {print $4}') + 1) / 2)) \
    -p 2222:22 -p 8006:8006 \
    -v "$_ISO":/boot.iso \
    "$_CONTAINER_IMAGE"
}

run_on_target() { ssh-keygen -R '[localhost]:2222' >/dev/null 2>&1 && ssh \
  -o ConnectTimeout=1 -o StrictHostKeyChecking=accept-new \
  -p 2222 -q root@localhost "$@"; }

test_connection() {
  printf 'Attempting to connect to target...' && start_time=$(date +%s) && while true; do
    current_time=$(date +%s) && elapsed=$((current_time - start_time))
    [ "$elapsed" -ge 300 ] && echo '' && return 1
    run_on_target 'exit' && echo '' && return 0
    printf '.' && sleep 1
  done
}

cleanup_containers() { podman rm -f dots-test static-server; }

prepare_container() {
  _ARCH=$1 && _BOOT_MODE=$2

  cleanup_containers && create_container "$_ARCH" "$_BOOT_MODE"
  ! test_connection && cleanup_containers && return 1
}

run_test() {
  ! test_connection && return 1

  run_on_target 'setup-apkrepos -1 && apk update'
  run_on_target 'apk add curl dosfstools e2fsprogs tar util-linux xz'
  ! run_on_target "curl -Lfs -- https://raw.githubusercontent.com/pedro-pereira-dev/dotfiles/refs/heads/main/install-gentoo.sh | \
    sh -s -- --hostname gv-test --password root" && return 1

  run_on_target 'echo "PermitEmptyPasswords yes" >> /mnt/etc/ssh/sshd_config.d/dots-test.conf'
  run_on_target 'echo "PermitRootLogin yes" >> /mnt/etc/ssh/sshd_config.d/dots-test.conf'
  run_on_target 'chroot /mnt /bin/bash -c "passwd -d root && rc-update add sshd default" && reboot'

  sleep 60 && ! test_connection && cleanup_containers && return 1
  run_on_target 'emerge --ask=n app-misc/fastfetch && fastfetch && poweroff'
}

run_test_suite() {
  _ARCH=$1 && _BOOT_MODE=$2

  ! prepare_container "$_ARCH" "$_BOOT_MODE" && return 1
  ! test_connection && cleanup_containers && return 1

  ! run_test && return 1

  cleanup_containers && return 0
}
