#!/usr/bin/env bash
set -euo pipefail

if ! command -v wpctl >/dev/null 2>&1; then
  printf '{"text":"","tooltip":"wpctl not found","class":"muted"}\n'
  exit 0
fi

info=$(wpctl get-volume @DEFAULT_AUDIO_SINK@ 2>/dev/null || true)
if [ -z "$info" ]; then
  printf '{"text":"","tooltip":"No default sink","class":"muted"}\n'
  exit 0
fi

if printf '%s' "$info" | grep -q '\[MUTED\]'; then
  printf '{"text":"","tooltip":"Output muted","class":"muted"}\n'
else
  printf '{"text":"","tooltip":"Output unmuted","class":"on"}\n'
fi
