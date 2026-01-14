#!/usr/bin/env bash
set -euo pipefail

if ! command -v grim >/dev/null 2>&1; then
  exit 1
fi

output_dir="${HOME}/Pictures/Screenshots"
mkdir -p "$output_dir"
timestamp=$(date '+%Y-%m-%d_%H-%M-%S')
output_file="${output_dir}/screenshot_${timestamp}.png"

if command -v slurp >/dev/null 2>&1; then
  geometry=$(slurp)
  if [ -n "${geometry:-}" ]; then
    grim -g "$geometry" "$output_file"
    exit 0
  fi
fi

grim "$output_file"
