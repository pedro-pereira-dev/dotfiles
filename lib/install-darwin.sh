#!/usr/bin/env bash
# shellcheck disable=SC2016

install_darwin_xcode() {
  if ! xcode-select --print-path >/dev/null 2>&1; then
    xcode-select --install || true
    until xcode-select --print-path >/dev/null 2>&1; do sleep 60; done
  fi
}

install_darwin_homebrew() {
  if [[ ! -x /opt/homebrew/bin/brew ]]; then NONINTERACTIVE=1 \
    bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"; fi
  _prepend_path() { if [[ -d $1 && ":$PATH:" != *":$1:"* ]]; then export PATH="$1:$PATH"; fi; }
  _prepend_path /opt/homebrew/sbin
  _prepend_path /opt/homebrew/bin
}

install_darwin_git() { if ! brew list --formula git >/dev/null 2>&1; then brew install git; fi; }
install_darwin_bash() { if ! brew list --formula bash >/dev/null 2>&1; then brew install bash; fi; }

set_darwin_bash_shell() {
  local _bash=/opt/homebrew/bin/bash
  if ! grep -qxF "$_bash" /etc/shells; then printf '%s\n' "$_bash" | sudo tee -a /etc/shells >/dev/null; fi
  if ! dscl . -read "/Users/$USER" UserShell | grep -qxF "UserShell: $_bash"; then sudo chsh -s "$_bash" "$USER"; fi
}

install_darwin_lima_vm() {
  local _name=teste
  local _mirror=https://gentoo.osuosl.org/releases/arm64/autobuilds/current-di-arm64-cloudinit
  # skips if the vm already exists
  if [[ -n $(limactl list --format '{{.Status}}' "$_name" 2>/dev/null || true) ]]; then return 0; fi
  # cpus - all except 4 for host, min 1
  _cpus=$(($(sysctl -n hw.ncpu) - 4))
  ((_cpus >= 1)) || _cpus=1
  # ram - all except 8gib for host, min 1gib
  _memsize=$(sysctl -n hw.memsize)
  _mem=$((_memsize / 1073741824 - 8))
  ((_mem >= 1)) || _mem=1
  # disk - all except 256gib for host, min 16gib
  _free=$(df -k "$HOME" | awk 'NR==2 {print int($4 / 1048576)}')
  _disk=$((_free - 256))
  ((_disk >= 16)) || _disk=16
  # latest cloud init
  _file=$(curl -fsSL "$_mirror/latest-di-arm64-cloudinit.txt" | awk '/^di-arm64-cloudinit-.*\.qcow2 /{print $1; exit}')
  _sha=$(curl -fsSL "$_mirror/$_file.sha256" | awk -v f="$_file" '$2 == f && $1 ~ /^[0-9a-f]{64}$/ {print $1; exit}')

  _config=$(mktemp -t lima-gentoo).yml
  {
    echo 'images:'
    echo '  - arch: aarch64'
    echo "    digest: sha256:$_sha"
    echo "    location: $_mirror/$_file"
    echo ''
    echo "cpus: $_cpus"
    echo "memory: ${_mem}GiB"
    echo "disk: ${_disk}GiB"
    echo ''
    echo 'mounts:'
    echo '  - location: "{{.Home}}"'
    echo '    mountPoint: /mnt/host/home'
    echo '    writable: true'
    echo '  - location: /tmp'
    echo '    mountPoint: /mnt/host/tmp'
    echo '    writable: true'
    echo '  - location: "{{.Home}}/Downloads"'
    echo '    mountPoint: "/home/{{.User}}.guest/Downloads"'
    echo '    writable: true'
    echo '  - location: "{{.Home}}/workspace"'
    echo '    mountPoint: "/home/{{.User}}.guest/workspace"'
    echo '    writable: true'
    echo ''
    echo 'provision:'
    echo '  - mode: system'
    echo '    script: |'
    echo '      #!/bin/bash'
    echo '      set -euo pipefail'
    echo '      hostnamectl set-hostname gentoo-lima'
    echo '      localectl set-keymap pt-latin9'
    echo '      localectl set-locale LANG=en_US.UTF-8'
    echo '      timedatectl set-timezone Europe/Lisbon'
  } >"$_config"

  limactl create -y --name "$_name" "$_config"
  limactl autostart enable "$_name"
  limactl start "$_name"
  limactl shell "$_name" bash -c 'bash -c "$(curl -fsSL https://raw.githubusercontent.com/pedro-pereira-dev/dotfiles/main/bootstrap)"'
}
