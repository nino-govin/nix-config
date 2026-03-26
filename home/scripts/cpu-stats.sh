#!/bin/sh
# CPU usage (delta /proc/stat) + température

read -r _ u1 n1 s1 i1 w1 r1 f1 _ < /proc/stat
sleep 1
read -r _ u2 n2 s2 i2 w2 r2 f2 _ < /proc/stat

TOTAL=$(( (u2+n2+s2+i2+w2+r2+f2) - (u1+n1+s1+i1+w1+r1+f1) ))
IDLE=$(( i2 - i1 ))
USAGE=$(( (TOTAL - IDLE) * 100 / TOTAL ))

TEMP_RAW=$(cat /sys/class/thermal/thermal_zone6/temp 2>/dev/null)
TEMP=$((TEMP_RAW / 1000))

CLASS="normal"
if [ "$TEMP" -gt 90 ]; then CLASS="critical"; fi

printf '{"text": "%d%% %d°C", "tooltip": "CPU: %d%%\\nTemp: %d°C", "class": "%s"}\n' \
  "$USAGE" "$TEMP" "$USAGE" "$TEMP" "$CLASS"
