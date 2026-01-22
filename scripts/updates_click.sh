#!/usr/bin/env bash
set -euo pipefail

exec "$HOME/.config/waybar/scripts/toggle_window.sh" updates-list \
  /usr/bin/kitty --class updates-list -e /usr/bin/bash -lc '
    if command -v checkupdates >/dev/null 2>&1; then
      updates=$(checkupdates 2>/dev/null || true)
    else
      updates=""
    fi
    if [ -z "$updates" ]; then
      updates=$(pacman -Qu 2>/dev/null || true)
    fi
    if [ -n "$updates" ]; then
      printf "%s\n" "$updates"
    else
      echo "No updates (or sync required)."
    fi
    echo
    read -n1 -rsp "Press any key to close"
  '
