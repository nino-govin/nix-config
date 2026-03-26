#!/bin/sh
# Retourne les stats GPU Nvidia au format JSON pour waybar
# Requiert nvidia-smi

GPU_UTIL=$(nvidia-smi --query-gpu=utilization.gpu --format=csv,noheader,nounits 2>/dev/null | tr -d ' ')
GPU_TEMP=$(nvidia-smi --query-gpu=temperature.gpu --format=csv,noheader,nounits 2>/dev/null | tr -d ' ')
VRAM_USED=$(nvidia-smi --query-gpu=memory.used --format=csv,noheader,nounits 2>/dev/null | tr -d ' ')
VRAM_TOTAL=$(nvidia-smi --query-gpu=memory.total --format=csv,noheader,nounits 2>/dev/null | tr -d ' ')

if [ -z "$GPU_UTIL" ]; then
  echo '{"text": " N/A", "tooltip": "GPU indisponible", "class": "inactive"}'
  exit 0
fi

VRAM_USED_GB=$(echo "scale=1; $VRAM_USED / 1024" | bc)
VRAM_TOTAL_GB=$(echo "scale=1; $VRAM_TOTAL / 1024" | bc)

CLASS="normal"
if [ "$GPU_UTIL" -gt 80 ]; then CLASS="high"; fi
if [ "$GPU_TEMP" -gt 85 ]; then CLASS="critical"; fi

TEXT=" ${GPU_UTIL}%"
TOOLTIP="GPU: ${GPU_UTIL}% — ${GPU_TEMP}°C\nVRAM: ${VRAM_USED_GB}G / ${VRAM_TOTAL_GB}G"

printf '{"text": "%s", "tooltip": "%s", "class": "%s"}\n' "$TEXT" "$TOOLTIP" "$CLASS"
