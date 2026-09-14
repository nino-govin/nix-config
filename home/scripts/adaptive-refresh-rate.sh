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

is_gaming() {
    pgrep -x "osu!.exe" > /dev/null 2>&1 || pgrep -x "wine" > /dev/null 2>&1
}

if is_gaming; then
    exit 0
fi

if is_on_ac; then
    hyprctl eval "hl.monitor({ output = '$MONITOR', mode = '${RESOLUTION}@240', position = '$POSITION', scale = $SCALE })"
else
    hyprctl eval "hl.monitor({ output = '$MONITOR', mode = '${RESOLUTION}@60', position = '$POSITION', scale = $SCALE })"
fi
