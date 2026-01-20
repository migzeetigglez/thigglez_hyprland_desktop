#!/usr/bin/env bash
set -euo pipefail

if ! command -v grim >/dev/null 2>&1; then
  exit 1
fi

output_dir="${HOME}/Pictures/Screenshots"
mkdir -p "$output_dir"
timestamp=$(date '+%Y-%m-%d_%H-%M-%S')
output_file="${output_dir}/screenshot_${timestamp}.png"

open_in_dolphin() {
  if command -v dolphin >/dev/null 2>&1; then
    nohup dolphin --select "$output_file" >/dev/null 2>&1 &
  else
    nohup xdg-open "$output_dir" >/dev/null 2>&1 &
  fi
}

if command -v magick >/dev/null 2>&1; then
  grim -t ppm - | magick - -colorspace sRGB -auto-level "$output_file"
else
  grim "$output_file"
fi

open_in_dolphin
