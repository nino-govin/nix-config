#!/usr/bin/env bash
MODE="$1"

sudo /run/current-system/sw/bin/power-profile-apply "$MODE"

_visuals_on() {
    hyprctl eval "hl.config({ animations = { enabled = true } })"
    hyprctl eval "hl.config({ decoration = { blur = { enabled = true }, shadow = { enabled = true } } })"
}

_visuals_off() {
    hyprctl eval "hl.config({ animations = { enabled = false } })"
    hyprctl eval "hl.config({ decoration = { blur = { enabled = false }, shadow = { enabled = false } } })"
}

case "$MODE" in
  performance)
    hyprctl eval "hl.monitor({ output = 'eDP-1', mode = '2560x1600@240', position = '0x0', scale = 1.6 })"
    _visuals_on
    ;;
  balanced)
    ~/.local/bin/adaptive-refresh-rate
    _visuals_on
    ;;
  economy)
    hyprctl eval "hl.monitor({ output = 'eDP-1', mode = '2560x1600@60', position = '0x0', scale = 1.6 })"
    _visuals_off
    ;;
  *)
    exit 1
    ;;
esac

echo "$MODE" > "${XDG_DATA_HOME:-$HOME/.local/share}/power-profile"
