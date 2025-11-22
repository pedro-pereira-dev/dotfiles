#!/bin/sh
set -eou pipefail

_UNATTENDED='' && [ $# -eq 1 ] && [ "$1" = --unattended ] && _UNATTENDED=$1
eupdate
eupgrade "$_UNATTENDED"
edeclare "$_UNATTENDED"
edelete "$_UNATTENDED"
exit 0
