#!/usr/bin/env bash

# Script pour ajuster le taux de rafraîchissement selon l'alimentation
# 240Hz sur secteur, 60Hz sur batterie

MONITOR="eDP-1"
RESOLUTION="2560x1600"
SCALE="1.6"
POSITION="0x0"

# Détecte si on est sur secteur
is_on_ac() {
    # Cherche dans tous les adaptateurs AC possibles
    for ac in /sys/class/power_supply/AC*/online /sys/class/power_supply/ADP*/online; do
        if [ -f "$ac" ]; then
            [ "$(cat "$ac")" = "1" ] && return 0
        fi
    done
    return 1
}

# Applique le taux de rafraîchissement approprié
if is_on_ac; then
    # Sur secteur : 240Hz
    hyprctl keyword monitor "$MONITOR,$RESOLUTION@240,$POSITION,$SCALE"
else
    # Sur batterie : 60Hz
    hyprctl keyword monitor "$MONITOR,$RESOLUTION@60,$POSITION,$SCALE"
fi
