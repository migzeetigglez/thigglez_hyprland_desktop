#!/usr/bin/env bash
set -euo pipefail

if command -v checkupdates >/dev/null 2>&1; then
  updates=$(checkupdates 2>/dev/null || true)
else
  updates=$(pacman -Qu 2>/dev/null || true)
fi

count=$(printf '%s
' "$updates" | sed '/^$/d' | wc -l | tr -d ' ')

if [ "$count" -eq 0 ]; then
  printf '{"text":" 0","tooltip":"No updates","class":"ok"}\n'
  exit 0
fi

preview=$(printf '%s
' "$updates" | sed -n '1,10p' | sed ':a;N;$!ba;s/\n/\\n/g')

printf '{"text":" %s","tooltip":"%s","class":"warn"}\n' "$count" "$preview"
