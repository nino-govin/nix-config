#!/bin/sh

INTEL_CARD=""
for card in /sys/class/drm/card*/; do
  vendor="${card}device/vendor"
  if [ -f "$vendor" ] && grep -q "0x8086" "$vendor" 2>/dev/null; then
    INTEL_CARD=$(basename "$card")
    break
  fi
done

if [ -z "$INTEL_CARD" ]; then
  printf '{"text": "Intel N/A", "tooltip": "iGPU introuvable", "class": "inactive"}\n'
  exit 0
fi

CARD_PATH="/sys/class/drm/${INTEL_CARD}"
CUR=$(cat "${CARD_PATH}/gt_cur_freq_mhz" 2>/dev/null || echo "0")
MAX=$(cat "${CARD_PATH}/gt_max_freq_mhz" 2>/dev/null || echo "1")

if [ "$MAX" -le 0 ]; then MAX=1; fi
USAGE=$((CUR * 100 / MAX))

printf '{"text": "Intel %d%%", "tooltip": "iGPU: %dMHz / %dMHz", "class": "normal"}\n' \
  "$USAGE" "$CUR" "$MAX"
