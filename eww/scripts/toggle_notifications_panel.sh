#!/usr/bin/env bash
set -euo pipefail

CONFIG="/home/thigglez/.config/eww"

if eww --config "$CONFIG" active-windows | awk -F': ' '$2 == "notifications_panel" {found=1} END {exit !found}'; then
  eww --config "$CONFIG" close notifications_panel
else
  eww --config "$CONFIG" open notifications_panel
fi
