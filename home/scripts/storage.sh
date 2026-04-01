#!/bin/sh

USAGE=$(df -h / | awk 'NR==2 {print $3 "/" $2 " (" $5 ")"}')
PERCENT=$(df / | awk 'NR==2 {gsub("%",""); print $5}')

CLASS="normal"
if [ "$PERCENT" -gt 80 ]; then CLASS="warning"; fi
if [ "$PERCENT" -gt 90 ]; then CLASS="critical"; fi

printf '{"text": " %s", "tooltip": "Stockage: %s", "class": "%s"}\n' "$USAGE" "$USAGE" "$CLASS"
