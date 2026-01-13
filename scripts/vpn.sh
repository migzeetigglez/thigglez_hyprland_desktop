#!/usr/bin/env bash
set -euo pipefail

json_escape() {
  printf '%s' "$1" | sed ':a;N;$!ba;s/\\/\\\\/g; s/"/\\"/g; s/\r//g; s/\n/\\\\n/g'
}

if ! command -v mullvad >/dev/null 2>&1; then
  printf '{"text":" VPN","tooltip":"mullvad not found","class":"off"}\n'
  exit 0
fi

status=$(mullvad status 2>&1 || true)
if [ -z "$status" ]; then
  printf '{"text":" VPN","tooltip":"mullvad status returned no output","class":"off"}\n'
  exit 0
fi

if printf '%s' "$status" | grep -q "Connected"; then
  location=$(printf '%s\n' "$status" | sed -n 's/^    Visible location: //p' | head -n 1)
  if [ -n "$location" ]; then
    tooltip="$location"
  else
    tooltip="$status"
  fi
  tooltip=$(json_escape "$tooltip")
  printf '{"text":" VPN","tooltip":"%s","class":"on"}\n' "$tooltip"
else
  tooltip=$(json_escape "$status")
  printf '{"text":" VPN","tooltip":"%s","class":"off"}\n' "$tooltip"
fi
