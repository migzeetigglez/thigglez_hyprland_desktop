#!/usr/bin/env bash
set -euo pipefail

if pgrep -x wf-recorder >/dev/null 2>&1; then
  pkill -x wf-recorder
  exit 0
fi

if ! command -v wf-recorder >/dev/null 2>&1; then
  exit 1
fi

output_dir="${HOME}/Videos/recordings"
mkdir -p "$output_dir"
timestamp=$(date '+%Y-%m-%d_%H-%M-%S')
output_file="${output_dir}/recording_${timestamp}.mp4"

if command -v slurp >/dev/null 2>&1; then
  geometry=$(slurp)
  if [ -n "${geometry:-}" ]; then
    nohup wf-recorder -g "$geometry" -f "$output_file" >/dev/null 2>&1 &
    exit 0
  fi
fi

nohup wf-recorder -f "$output_file" >/dev/null 2>&1 &
