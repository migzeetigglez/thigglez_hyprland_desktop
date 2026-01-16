#!/usr/bin/env bash
set -euo pipefail

notify_missing_calendar() {
  local cache_dir="${XDG_RUNTIME_DIR:-/tmp}"
  local stamp="${cache_dir}/eww-calendar-missing.stamp"
  local now last

  now=$(date +%s)
  last=0
  if [[ -f "$stamp" ]]; then
    read -r last <"$stamp" || last=0
  fi
  if [[ ! "$last" =~ ^[0-9]+$ ]]; then
    last=0
  fi
  if (( now - last < 3600 )); then
    return 0
  fi

  printf '%s\n' "$now" >"$stamp"
  if command -v notify-send >/dev/null 2>&1; then
    notify-send "Eww" "No calendar app found. Set EWW_CALENDAR_CMD to override."
  fi
}

if [[ -n "${EWW_CALENDAR_CMD:-}" ]]; then
  exec ${EWW_CALENDAR_CMD}
fi

if command -v kitty >/dev/null 2>&1; then
  if command -v khal >/dev/null 2>&1; then
    exec kitty -e khal interactive
  fi
  if command -v calcurse >/dev/null 2>&1; then
    exec kitty -e calcurse
  fi
fi

if command -v gnome-calendar >/dev/null 2>&1; then
  exec gnome-calendar
fi

notify_missing_calendar
