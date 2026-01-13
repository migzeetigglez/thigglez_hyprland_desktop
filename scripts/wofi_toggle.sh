#!/usr/bin/env bash
set -euo pipefail

if pgrep -f "wofi --show drun" >/dev/null 2>&1; then
  pkill -f "wofi --show drun"
  exit 0
fi

wofi --show drun --prompt "pick your poison" --conf /home/thigglez/.config/wofi/config >/dev/null 2>&1 &
