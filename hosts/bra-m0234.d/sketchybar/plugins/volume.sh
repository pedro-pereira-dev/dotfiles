#!/usr/bin/env bash

_volume=${INFO:-$(osascript -e 'output volume of (get volume settings)')}
[[ $_volume =~ ^[0-9]+$ ]] || exit 0

if ((_volume == 0)); then
	sketchybar --set "$NAME" label="MUTE"
else
	sketchybar --set "$NAME" label="VOL $_volume%"
fi
