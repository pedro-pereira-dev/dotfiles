#!/bin/bash
setxkbmap pt
xinput set-prop "DELL08B8:00 0488:121F Touchpad" "libinput Tapping Enabled" 1
xinput set-prop "DELL08B8:00 0488:121F Touchpad" "libinput Natural Scrolling Enabled" 1
gentoo-pipewire-launcher restart &
[ -d "${HOME}/.config/autosetup" ] && find ${HOME}/.config/autosetup -exec {} \;
exec dbus-launch --sh-syntax --exit-with-session jwm -f ~/.config/jwm/config.xml
