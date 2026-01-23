#!/usr/bin/env bash
set -euo pipefail

exec "$HOME/.config/waybar/scripts/toggle_window.sh" updates-list \
  /usr/bin/kitty --class updates-list -e /usr/bin/bash -lc '
    /home/thigglez/.config/waybar/scripts/updates.sh --list
    echo
    read -n1 -rsp "Press any key to close"
  '
