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

use_tonemap=false
if command -v magick >/dev/null 2>&1; then
  use_tonemap=true
fi

grab_with_grim() {
  local geometry="${1:-}"
  if [ "$use_tonemap" = true ]; then
    if [ -n "$geometry" ]; then
      grim -t ppm -g "$geometry" - | magick - -colorspace sRGB -auto-level "$output_file"
    else
      grim -t ppm - | magick - -colorspace sRGB -auto-level "$output_file"
    fi
  else
    if [ -n "$geometry" ]; then
      grim -g "$geometry" "$output_file"
    else
      grim "$output_file"
    fi
  fi
}

if command -v slurp >/dev/null 2>&1; then
  geometry=$(slurp)
  if [ -n "${geometry:-}" ]; then
    grab_with_grim "$geometry"
    open_in_dolphin
    exit 0
  fi
fi

grab_with_grim
open_in_dolphin
