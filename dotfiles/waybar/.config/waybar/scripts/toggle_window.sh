#!/usr/bin/env bash
set -euo pipefail

PATH="/usr/bin:/bin:/usr/local/bin"
HYPRCTL="$(command -v hyprctl || true)"
JQ="$(command -v jq || true)"

if [ -z "$HYPRCTL" ] || [ -z "$JQ" ]; then
  echo "Missing hyprctl or jq in PATH" >&2
  exit 1
fi

if [ "$#" -lt 2 ]; then
  echo "Usage: $0 <class> <command...>" >&2
  exit 2
fi

class="$1"
shift

if [ -z "${HYPRLAND_INSTANCE_SIGNATURE:-}" ]; then
  sig="$(ls -td /tmp/hypr/* 2>/dev/null | head -n1 | xargs -I{} basename {})"
  if [ -n "$sig" ]; then
    export HYPRLAND_INSTANCE_SIGNATURE="$sig"
  fi
fi

clients_json="$("$HYPRCTL" -j clients 2>/dev/null || true)"
if [ -z "$clients_json" ] || [ "${clients_json#\[}" = "$clients_json" ]; then
  "$@" >/dev/null 2>&1 &
  exit 0
fi

addr="$(printf '%s' "$clients_json" | "$JQ" -r --arg class "$class" '.[] | select((.class|ascii_downcase) == ($class|ascii_downcase)) | .address' | head -n1)"

if [ -n "$addr" ] && [ "$addr" != "null" ]; then
"$HYPRCTL" dispatch closewindow "address:$addr"
  exit 0
fi

"$@" >/dev/null 2>&1 &
