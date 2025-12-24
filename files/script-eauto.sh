#!/bin/sh
set -eou pipefail

_unattended=''
[ $# -eq 1 ] && [ "$1" = --unattended ] && _unattended=$1

eupdate
eupgrade "$_unattended"
edeclare "$_unattended"
edelete "$_unattended"
