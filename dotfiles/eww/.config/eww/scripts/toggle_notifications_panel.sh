#!/usr/bin/env bash
set -euo pipefail

CONFIG="/home/thigglez/.config/eww"

action="${1:-toggle}"

is_open() {
  eww --config "$CONFIG" active-windows | awk -F': ' '$2 == "notifications_panel" {found=1} END {exit !found}'
}

if [[ "$action" == "open" ]]; then
  eww --config "$CONFIG" update notif_panel_class="open"
  eww --config "$CONFIG" open notifications_panel
  exit 0
fi

if [[ "$action" == "close" ]]; then
  if is_open; then
    eww --config "$CONFIG" close notifications_panel
    eww --config "$CONFIG" update notif_panel_class="open"
  fi
  exit 0
fi

if is_open; then
  eww --config "$CONFIG" close notifications_panel
  eww --config "$CONFIG" update notif_panel_class="open"
else
  eww --config "$CONFIG" update notif_panel_class="open"
  eww --config "$CONFIG" open notifications_panel
fi
