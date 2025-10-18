#!/bin/sh
_TEMP_DIR='/tmp/test-install-gentoo.d'
mkdir -p $_TEMP_DIR
podman run -it --rm \
  --device=/dev/kvm \
  --name qemu-test-install-gentoo \
  -e 'BOOT=alpine' \
  -p 8006:8006 \
  -v "$_TEMP_DIR:/storage" \
  docker.io/qemux/qemu
rm -fr $_TEMP_DIR
