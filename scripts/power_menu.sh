#!/usr/bin/env bash
set -euo pipefail

if ! command -v wofi >/dev/null 2>&1; then
  exit 1
fi

if pgrep -f "wofi --dmenu --prompt Power" >/dev/null 2>&1; then
  pkill -f "wofi --dmenu --prompt Power"
  exit 0
fi

choice=$(printf 'Lock\nSleep\nHibernate\nRestart\nShutdown\nLogout' | wofi --dmenu --prompt 'Power' --width 240 --height 300)

case "$choice" in
  Lock)
    if command -v hyprlock >/dev/null 2>&1; then
      hyprlock
    elif command -v loginctl >/dev/null 2>&1; then
      loginctl lock-session
    fi
    ;;
  Sleep)
    systemctl suspend
    ;;
  Hibernate)
    systemctl hibernate
    ;;
  Restart)
    systemctl reboot
    ;;
  Shutdown)
    systemctl poweroff
    ;;
  Logout)
    if command -v hyprctl >/dev/null 2>&1; then
      hyprctl dispatch exit
    else
      loginctl terminate-user "$USER"
    fi
    ;;
  *)
    exit 0
    ;;
esac
