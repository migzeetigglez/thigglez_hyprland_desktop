#!/usr/bin/env bash
set -euo pipefail

app_cmd="mullvad-vpn"
class_name="Mullvad VPN"
log_file="/tmp/waybar-mullvad-toggle.log"
last_ws_file="/tmp/waybar-mullvad-last-ws"

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

center_window() {
  hyprctl dispatch focuswindow address:"$addr" >/dev/null
  hyprctl dispatch centerwindow >/dev/null
}

active_addr=$(hyprctl activewindow | awk '/^Window/ {print $2; exit} /^address:/ {print $2; exit}')
if [ -n "${active_addr:-}" ] && [[ "$active_addr" != 0x* ]]; then
  active_addr="0x$active_addr"
fi
active_ws=$(hyprctl activeworkspace | awk '/^workspace:/ {print $2; exit}')
if [ -z "${active_ws:-}" ]; then
  active_ws=$(hyprctl activewindow | awk '/workspace:/ {print $2; exit}')
fi

id=$(find_window_id)
if [ -z "$id" ]; then
  nohup "$app_cmd" >/dev/null 2>&1 &
  exit 0
fi

addr="0x$id"
ws=$(find_window_ws)

printf '[%s] active_ws=%s active_addr=%s mullvad_ws=%s mullvad_addr=%s\n' \
  "$(date '+%F %T')" \
  "${active_ws:-?}" \
  "${active_addr:-?}" \
  "${ws:-?}" \
  "${addr:-?}" >> "$log_file"

is_special_ws=false
case "$ws" in
  -99|-98|special:*)
    is_special_ws=true
    ;;
esac

if [ -n "$active_ws" ] && [ "$ws" = "$active_ws" ]; then
  if [ "$active_ws" != "-99" ] && [ "$active_ws" != "-98" ]; then
    printf '%s\n' "$active_ws" > "$last_ws_file"
  fi
  hyprctl dispatch movetoworkspacesilent special,address:"$addr" >/dev/null
  if [ "$active_ws" != "-99" ] && [ "$active_ws" != "-98" ]; then
    hyprctl dispatch focusworkspaceoncurrentmonitor "$active_ws" >/dev/null
  fi
  exit 0
fi

if [ "$is_special_ws" = true ]; then
  target_ws="1"
  if [ -f "$last_ws_file" ]; then
    target_ws=$(head -n 1 "$last_ws_file" | tr -cd '0-9')
    if [ -z "$target_ws" ]; then
      target_ws="1"
    fi
  fi
  hyprctl dispatch movetoworkspacesilent "$target_ws",address:"$addr" >/dev/null
  center_window
  exit 0
fi

if [ -n "${active_ws:-}" ]; then
  hyprctl dispatch movetoworkspacesilent "$active_ws",address:"$addr" >/dev/null
  center_window
else
  hyprctl dispatch movetoworkspacesilent special,address:"$addr" >/dev/null
fi
