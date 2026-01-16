#!/usr/bin/env bash
set -euo pipefail

pid_file="/tmp/hyprtrails-rainbow.pid"
alpha="0.35"
interval="0.37"
theme_file="${HYPRTRAILS_THEME_FILE:-$HOME/.config/waybar/style.css}"

reset_color() {
  color="$(
    python - <<'PY' "$theme_file" "sky" "$alpha"
import re
import sys

theme_file = sys.argv[1]
name = sys.argv[2]
alpha = sys.argv[3]

def parse_rgb(value):
    m = re.match(r"rgba?\(([^)]+)\)", value.replace(" ", ""))
    if m:
        parts = m.group(1).split(",")
        if len(parts) >= 3:
            return int(float(parts[0])), int(float(parts[1])), int(float(parts[2]))
    m = re.match(r"#([0-9a-fA-F]{6})", value.strip())
    if m:
        hexv = m.group(1)
        return int(hexv[0:2], 16), int(hexv[2:4], 16), int(hexv[4:6], 16)
    return None

colors = {}
try:
    with open(theme_file, "r", encoding="utf-8") as fh:
        for line in fh:
            m = re.search(r"@define-color\s+(\w+)\s+([^;]+);", line)
            if m:
                colors[m.group(1)] = m.group(2).strip()
except FileNotFoundError:
    colors = {}

value = colors.get(name, "#5D9EAA")
rgb = parse_rgb(value) or (93, 158, 170)
print(f"rgba({rgb[0]}, {rgb[1]}, {rgb[2]}, {alpha})")
PY
  )"
  hyprctl keyword plugin:hyprtrails:color "$color" >/dev/null 2>&1 || true
}

if [ -f "$pid_file" ] && kill -0 "$(cat "$pid_file")" >/dev/null 2>&1; then
  kill "$(cat "$pid_file")" >/dev/null 2>&1 || true
  rm -f "$pid_file"
  reset_color
  exit 0
fi

python - <<'PY' "$alpha" "$interval" "$theme_file" &
import subprocess
import sys
import time
import re

alpha = sys.argv[1]
interval = float(sys.argv[2])
theme_file = sys.argv[3]

def parse_rgb(value):
    m = re.match(r"rgba?\(([^)]+)\)", value.replace(" ", ""))
    if m:
        parts = m.group(1).split(",")
        if len(parts) >= 3:
            return int(float(parts[0])), int(float(parts[1])), int(float(parts[2]))
    m = re.match(r"#([0-9a-fA-F]{6})", value.strip())
    if m:
        hexv = m.group(1)
        return int(hexv[0:2], 16), int(hexv[2:4], 16), int(hexv[4:6], 16)
    return None

colors = {}
try:
    with open(theme_file, "r", encoding="utf-8") as fh:
        for line in fh:
            m = re.search(r"@define-color\s+(\w+)\s+([^;]+);", line)
            if m:
                colors[m.group(1)] = m.group(2).strip()
except FileNotFoundError:
    colors = {}

ordered = ["clay", "wheat", "sky", "moss", "dusk", "rose"]
palette = []
for name in ordered:
    value = colors.get(name)
    if value:
        rgb = parse_rgb(value)
        if rgb:
            palette.append(rgb)

if not palette:
    palette = [
        (214, 93, 14),   # clay
        (215, 153, 33),  # wheat
        (93, 158, 170),  # sky
        (122, 183, 123), # moss
        (196, 123, 161), # dusk
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
