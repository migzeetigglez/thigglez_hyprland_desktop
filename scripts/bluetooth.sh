#!/usr/bin/env bash
set -euo pipefail

if ! command -v bluetoothctl >/dev/null 2>&1; then
  printf '{"text":"","tooltip":"bluetoothctl not found","class":"off"}\n'
  exit 0
fi

powered=$(bluetoothctl show | awk -F': ' '/Powered/ {print $2; exit}')
if [ "$powered" != "yes" ]; then
  printf '{"text":" off","tooltip":"Bluetooth off","class":"off"}\n'
  exit 0
fi

connected=$(bluetoothctl devices Connected | sed -n 's/^Device [^ ]\\+ //p')
if [ -z "$connected" ]; then
  printf '{"text":"","tooltip":"No devices connected","class":"on"}\n'
  exit 0
fi

name=$(printf '%s
' "$connected" | head -n 1)
count=$(printf '%s
' "$connected" | wc -l | tr -d ' ')

printf '{"text":" %s","tooltip":"%s","class":"on"}\n' "$count" "$name"
