#!/usr/bin/env bash
set -euo pipefail

app_cmd="mullvad-vpn"
class_name="Mullvad VPN"

find_window_id() {
  hyprctl clients | awk -v RS='' -v cls="$class_name" '
    /class:/{
      if ($0 ~ "class: " cls) {
        if (match($0, /^Window ([^ ]+)/, m)) {print m[1]; exit}
      }
    }
  '
}

find_window_ws() {
  hyprctl clients | awk -v RS='' -v cls="$class_name" '
    /class:/{
      if ($0 ~ "class: " cls) {
        if (match($0, /workspace: ([^ ]+)/, m)) {print m[1]; exit}
      }
    }
  '
}

active_ws=$(hyprctl activeworkspace | awk '/^workspace:/ {print $2; exit}')

id=$(find_window_id)
if [ -z "$id" ]; then
  nohup "$app_cmd" >/dev/null 2>&1 &
  exit 0
fi

addr="0x$id"
ws=$(find_window_ws)

if [ "$ws" = "-98" ] || [ "$ws" = "special:mullvad" ]; then
  if [ -n "$active_ws" ]; then
    hyprctl dispatch movetoworkspacesilent "$active_ws",address:"$addr" >/dev/null
  else
    hyprctl dispatch togglespecialworkspace mullvad >/dev/null
  fi
else
  hyprctl dispatch movetoworkspacesilent special:mullvad,address:"$addr" >/dev/null
fi
