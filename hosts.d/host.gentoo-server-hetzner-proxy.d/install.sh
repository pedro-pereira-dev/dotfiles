#!/bin/bash
set -eou pipefail

_SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"

# ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- -----
# symlinks dotfiles files to target system
run_as_root stow "$_SCRIPT_DIR/make.conf" '/etc/portage/make.conf'
run_as_root stow "$_SCRIPT_DIR/portage-accept-keywords.conf" '/etc/portage/package.accept_keywords'
run_as_root stow "$_SCRIPT_DIR/portage-package-declare.conf" '/etc/portage/package.declare'
run_as_root stow "$_SCRIPT_DIR/portage-package-license.conf" '/etc/portage/package.license'
run_as_root stow "$_SCRIPT_DIR/portage-package-mask.conf" '/etc/portage/package.mask'
run_as_root stow "$_SCRIPT_DIR/portage-package-unmask.conf" '/etc/portage/package.unmask'
run_as_root stow "$_SCRIPT_DIR/portage-package-use.conf" '/etc/portage/package.use'
