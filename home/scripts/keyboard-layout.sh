#!/usr/bin/env bash

DEVICES=$(hyprctl devices -j 2>/dev/null) || { printf '{"text":"??","tooltip":"hyprctl unavailable"}\n'; exit 0; }

LAYOUT=$(printf '%s' "$DEVICES" \
  | jq -r '.keyboards[] | select(.main == true) | .active_keymap // empty' 2>/dev/null \
  | head -1)

if [ -z "$LAYOUT" ]; then
  LAYOUT=$(printf '%s' "$DEVICES" \
    | jq -r '.keyboards[] | select(.name == "at-translated-set-2-keyboard") | .active_keymap // empty' 2>/dev/null)
fi

case "$LAYOUT" in
  "French")       SHORT="FR" ;;
  "English (US)") SHORT="EN" ;;
  "")             SHORT="??" ;;
  *)              SHORT="${LAYOUT:0:2}" ;;
esac

printf '{"text":"%s","tooltip":"%s"}\n' "$SHORT" "$LAYOUT"
