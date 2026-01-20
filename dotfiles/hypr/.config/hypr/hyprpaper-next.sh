#!/bin/sh
set -eu

WALL_DIR="${HYPRPAPER_WALL_DIR:-$HOME/.local/share/wallpapers}"
STATE_FILE="${XDG_CACHE_HOME:-$HOME/.cache}/hyprpaper-last-change"

get_monitors() {
  if command -v jq >/dev/null 2>&1; then
    hyprctl monitors -j 2>/dev/null | jq -r '.[].name' 2>/dev/null || true
  else
    hyprctl monitors 2>/dev/null | awk '/^Monitor /{print $2}' || true
  fi
}

wait_for_ipc() {
  i=0
  while [ "$i" -lt 20 ]; do
    if hyprctl hyprpaper list >/dev/null 2>&1; then
      return 0
    fi
    sleep 0.2
    i=$((i + 1))
  done
  return 1
}

if ! pgrep -x hyprpaper >/dev/null 2>&1; then
  hyprpaper >/dev/null 2>&1 &
  wait_for_ipc || true
fi

file="$(find "$WALL_DIR" -type f \( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' \) | shuf -n 1)"
if [ -n "$file" ]; then
  monitors="$(get_monitors)"
  if [ -n "$monitors" ]; then
    echo "$monitors" | while read -r monitor; do
      [ -n "$monitor" ] && hyprctl hyprpaper wallpaper "$monitor,$file"
    done
  else
    hyprctl hyprpaper wallpaper ",$file"
  fi
  date +%s > "$STATE_FILE"
fi
