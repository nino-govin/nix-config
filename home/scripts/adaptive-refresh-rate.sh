#!/usr/bin/env bash

MONITOR="eDP-1"
RESOLUTION="2560x1600"
SCALE="1.6"
POSITION="0x0"

is_on_ac() {
    for ac in /sys/class/power_supply/AC*/online /sys/class/power_supply/ADP*/online; do
        if [ -f "$ac" ]; then
            [ "$(cat "$ac")" = "1" ] && return 0
        fi
    done
    return 1
}

if is_on_ac; then
    hyprctl keyword monitor "$MONITOR,$RESOLUTION@240,$POSITION,$SCALE"
else
    hyprctl keyword monitor "$MONITOR,$RESOLUTION@60,$POSITION,$SCALE"
fi
