#!/usr/bin/env bash
set -euo pipefail

pid_file="/tmp/hyprtrails-rainbow.pid"
alpha="0.35"
interval="0.37"

reset_color() {
  hyprctl keyword plugin:hyprtrails:color "rgba(69,133,136,${alpha})" >/dev/null 2>&1 || true
}

if [ -f "$pid_file" ] && kill -0 "$(cat "$pid_file")" >/dev/null 2>&1; then
  kill "$(cat "$pid_file")" >/dev/null 2>&1 || true
  rm -f "$pid_file"
  reset_color
  exit 0
fi

python - <<'PY' "$alpha" "$interval" &
import subprocess
import sys
import time

alpha = sys.argv[1]
interval = float(sys.argv[2])

palette = [
    (214, 93, 14),   # clay
    (215, 153, 33),  # wheat
    (69, 133, 136),  # sky
    (104, 157, 106), # moss
    (177, 98, 134),  # dusk
]

idx = 0

while True:
    r, g, b = palette[idx]
    color = f"rgba({r}, {g}, {b}, {alpha})"
    subprocess.run(["hyprctl", "keyword", "plugin:hyprtrails:color", color],
                   stdout=subprocess.DEVNULL,
                   stderr=subprocess.DEVNULL)
    idx = (idx + 1) % len(palette)
    time.sleep(interval)
PY

echo $! > "$pid_file"
