#!/usr/bin/env bash

_device=$(networksetup -listallhardwareports | awk '/Wi-Fi/{getline; print $2; exit}')
_ip=$(ipconfig getifaddr "${_device:-en0}" 2>/dev/null)

if [[ -n $_ip ]]; then
	sketchybar --set "$NAME" label=WIFI label.color=0xffe2e2e3
else
	sketchybar --set "$NAME" label=OFFLINE label.color=0xff414550
fi
