#!/usr/bin/env bash

_pinned() {
	local _plist _count _i _id
	_plist=$(mktemp)
	defaults export com.apple.dock "$_plist"
	_count=$(plutil -extract persistent-apps raw -o - "$_plist" 2>/dev/null || echo 0)
	for ((_i = 0; _i < _count; _i++)); do
		_id=$(plutil -extract "persistent-apps.$_i.tile-data.bundle-identifier" raw -o - "$_plist" 2>/dev/null) || continue
		printf '%s\n' "$_id"
	done
	rm -f "$_plist"
}

_update() {
	local _args=() _asn _id _item
	while IFS= read -r _item; do
		_id=${_item#dock.}
		_asn=$(lsappinfo find bundleid="$_id" 2>/dev/null)
		if [[ -n $_asn ]]; then
			_args+=(--set "$_item" background.color=0x55e2e2e3)
			if lsappinfo info -only StatusLabel "$_asn" | grep -q '"label"="[^"]'; then
				_args+=(label.drawing=on)
			else
				_args+=(label.drawing=off)
			fi
		else
			_args+=(--set "$_item" background.color=0x00000000 label.drawing=off)
		fi
	done < <(sketchybar --query bar | grep -o '"dock\.[^"]*"' | tr -d '"')
	((${#_args[@]})) && sketchybar "${_args[@]}"
}

case ${1:-} in
pinned) _pinned ;;
*) _update ;;
esac
