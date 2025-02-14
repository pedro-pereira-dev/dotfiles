#!/bin/bash

STEP=5

CURRENT_VOLUME=$(wpctl get-volume @DEFAULT_SINK@ 2>/dev/null | awk '{print $NF}')
CURRENT_VOLUME=$(echo "${CURRENT_VOLUME} * 100" | bc --mathlib | grep --only-matching '^\w*')

NEW_VOLUME=$((CURRENT_VOLUME - STEP))
NEW_VOLUME=$((NEW_VOLUME < 0 ? 0 : NEW_VOLUME))

wpctl set-volume @DEFAULT_SINK@ ${NEW_VOLUME}% 2>/dev/null
