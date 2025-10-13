#!/bin/sh
run_as_root stow "$_HOME/$_DOTS_DIR/gentoo-portage.d/layer-bin-portage-eauto.sh" "/usr/bin/eauto"
run_as_root stow "$_HOME/$_DOTS_DIR/gentoo-portage.d/layer-bin-portage-edeclare.sh" "/usr/bin/edeclare"
run_as_root stow "$_HOME/$_DOTS_DIR/gentoo-portage.d/layer-bin-portage-edelete.sh" "/usr/bin/edelete"
run_as_root stow "$_HOME/$_DOTS_DIR/gentoo-portage.d/layer-bin-portage-eupdate.sh" "/usr/bin/eupdate"
run_as_root stow "$_HOME/$_DOTS_DIR/gentoo-portage.d/layer-bin-portage-eupgrade.sh" "/usr/bin/eupgrade"
run_as_root stow "$_HOME/$_DOTS_DIR/gentoo-portage.d/layer-portage-overlays.conf" '/etc/portage/repos.conf/overlays.conf'
run_as_root stow "$_HOME/$_DOTS_DIR/gentoo-portage.d/layer-portage-package-mask.conf" '/etc/portage/package.mask'

# if get_option "$_FULL_FLAG" "$@" || get_option "$_INSTALL_FLAG" "$@"; then
#   run_as_root "/usr/bin/eupdate"
#   run_as_root "/usr/bin/eupgrade" --unsupervised
#   run_as_root "/usr/bin/edeclare" --unsupervised
#   run_as_root "/usr/bin/edelete" --unsupervised
#   run_as_root eselect news read >/dev/null
# fi
