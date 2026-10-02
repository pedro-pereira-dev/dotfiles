#!/usr/bin/env bash

_info=$(pmset -g batt)
_percent=$(grep -Eo '[0-9]+%' <<<"$_info" | head -1 | tr -d '%')
[[ -n $_percent ]] || exit 0

_prefix=BAT
[[ $_info == *'AC Power'* ]] && _prefix=CHG

sketchybar --set "$NAME" label="$_prefix $_percent%"
