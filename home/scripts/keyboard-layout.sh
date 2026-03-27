#!/usr/bin/env bash
# Récupère le layout actif du clavier principal
LAYOUT=$(hyprctl devices -j 2>/dev/null \
  | jq -r '.keyboards[] | select(.main == true) | .active_keymap // empty' \
  | head -1)

# Si pas de clavier "main", prend le clavier intégré
if [ -z "$LAYOUT" ]; then
  LAYOUT=$(hyprctl devices -j 2>/dev/null \
    | jq -r '.keyboards[] | select(.name == "at-translated-set-2-keyboard") | .active_keymap // empty')
fi

case "$LAYOUT" in
  "French")       SHORT="FR" ;;
  "English (US)") SHORT="EN" ;;
  *)              SHORT="${LAYOUT:0:2}" ;;
esac

printf '{"text":"%s","tooltip":"%s"}\n' "$SHORT" "$LAYOUT"
