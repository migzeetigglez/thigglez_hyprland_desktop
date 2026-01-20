#!/usr/bin/env bash
set -euo pipefail

state_file="/tmp/waybar-screenrecord.out"

if pgrep -x wf-recorder >/dev/null 2>&1; then
  pkill -x wf-recorder
  if command -v ffmpeg >/dev/null 2>&1 && [ -f "$state_file" ]; then
    output_file=$(cat "$state_file")
    if [ -n "${output_file:-}" ] && [ -f "$output_file" ]; then
      nohup bash -c "
        for i in {1..20}; do
          pgrep -x wf-recorder >/dev/null 2>&1 || break
          sleep 0.2
        done
        tmp_file=\"${output_file%.mp4}_sdr.mp4\"
        ffmpeg -y -i \"$output_file\" -vf \"zscale=t=linear:npl=100,tonemap=tonemap=hable,zscale=t=bt709:m=bt709:r=tv\" -c:v libx264 -pix_fmt yuv420p \"$tmp_file\" >/dev/null 2>&1
        if [ -f \"$tmp_file\" ]; then
          mv -f \"$tmp_file\" \"$output_file\"
        fi
        if command -v dolphin >/dev/null 2>&1; then
          nohup dolphin --select \"$output_file\" >/dev/null 2>&1 &
        else
          nohup xdg-open \"$(dirname \"$output_file\")\" >/dev/null 2>&1 &
        fi
      " >/dev/null 2>&1 &
    fi
  fi
  exit 0
fi

if ! command -v wf-recorder >/dev/null 2>&1; then
  exit 1
fi

output_dir="${HOME}/Videos/recordings"
mkdir -p "$output_dir"
timestamp=$(date '+%Y-%m-%d_%H-%M-%S')
output_file="${output_dir}/recording_${timestamp}.mp4"
printf '%s\n' "$output_file" > "$state_file"

if command -v slurp >/dev/null 2>&1; then
  geometry=$(slurp)
  if [ -n "${geometry:-}" ]; then
    nohup wf-recorder -g "$geometry" -f "$output_file" >/dev/null 2>&1 &
    exit 0
  fi
fi

nohup wf-recorder -f "$output_file" >/dev/null 2>&1 &
