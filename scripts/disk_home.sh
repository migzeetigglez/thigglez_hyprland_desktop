#!/usr/bin/env bash
set -euo pipefail

if ! command -v df >/dev/null 2>&1; then
  printf '{"text":"","tooltip":"df not found","class":"off"}\n'
  exit 0
fi

line=$(df -h --output=pcent,avail /home | tail -n 1)
used=$(printf '%s' "$line" | awk '{print $1}')
avail=$(printf '%s' "$line" | awk '{print $2}')

printf '{"text":" %s","tooltip":"/home available: %s","class":"on"}\n' "$used" "$avail"
