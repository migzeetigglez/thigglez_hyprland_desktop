#!/usr/bin/env bash
set -euo pipefail

if ! command -v wpctl >/dev/null 2>&1; then
  printf '{"text":"","tooltip":"wpctl not found","class":"off"}\n'
  exit 0
fi

info=$(wpctl get-volume @DEFAULT_AUDIO_SOURCE@ 2>/dev/null || true)
if [ -z "$info" ]; then
  printf '{"text":"","tooltip":"No default source","class":"off"}\n'
  exit 0
fi

muted=$(printf '%s' "$info" | grep -q '\[MUTED\]' && echo "yes" || echo "no")
vol=$(printf '%s' "$info" | awk '{print $2}' | tr -d '\n')

# Convert 0.00-1.00 to 0-100
pct=$(awk -v v="$vol" 'BEGIN { printf "%d", v * 100 + 0.5 }')

if [ "$muted" = "yes" ]; then
  printf '{"text":" %s","tooltip":"Mic muted","class":"off"}\n' "$pct"
else
  printf '{"text":" %s","tooltip":"Mic on","class":"on"}\n' "$pct"
fi
