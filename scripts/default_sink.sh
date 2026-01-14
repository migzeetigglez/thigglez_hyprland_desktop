#!/usr/bin/env bash
set -euo pipefail

if ! command -v wpctl >/dev/null 2>&1 && ! command -v pactl >/dev/null 2>&1; then
  exit 0
fi

if command -v pactl >/dev/null 2>&1; then
  running_sink_id=$(pactl list short sink-inputs 2>/dev/null | awk '
    $5 == "RUNNING" {print $2; exit}
  ')
  if [ -z "$running_sink_id" ]; then
    running_sink_id=$(pactl list sink-inputs 2>/dev/null | awk -v RS='' '
      /Corked: no/ {
        for (i = 1; i <= NF; i++) {
          if ($i == "Sink:") {print $(i+1); exit}
        }
      }
    ')
  fi
  if [ -n "$running_sink_id" ]; then
    running_sink_name=$(pactl list short sinks 2>/dev/null | awk -v id="$running_sink_id" '$1 == id {print $2; exit}')
    current_sink=$(pactl info 2>/dev/null | awk -F': ' '/Default Sink/ {print $2; exit}')
    if [ -n "$running_sink_name" ] && [ "$running_sink_name" != "$current_sink" ]; then
      pactl set-default-sink "$running_sink_name" >/dev/null 2>&1 || true
    fi
    exit 0
  fi
fi

status=$(wpctl status 2>/dev/null || true)
if [ -z "$status" ]; then
  exit 0
fi

sinks=$(printf '%s\n' "$status" | awk '
  /Sinks:/ {in_section=1; next}
  /Sources:/ {in_section=0}
  in_section {print}
')

if [ -z "$sinks" ]; then
  exit 0
fi

streams=$(printf '%s\n' "$status" | awk '
  /Streams:/ {in_section=1; next}
  /Video/ {in_section=0}
  in_section {print}
')

current_id=$(printf '%s\n' "$sinks" | awk '
  /\*/ {
    if (match($0, /([0-9]+)\./, m)) {print m[1]; exit}
  }
')

pick_id=""

find_by_pattern() {
  local pattern="$1"
  printf '%s\n' "$sinks" | awk -v pat="$pattern" '
    {
      line=$0
      if (match(line, /([0-9]+)\. ([^[]+)/, m)) {
        id=m[1]
        name=m[2]
        gsub(/^ +| +$/, "", name)
        if (tolower(name) ~ tolower(pat)) {print id; exit}
      }
    }
  '
}

# If any stream is active on a sink, follow that sink.
active_sink_name=$(printf '%s\n' "$streams" | awk '
  /output_/ && />/ {
    line=$0
    sub(/^.*> /, "", line)
    sub(/\[.*$/, "", line)
    gsub(/^[ \t]+|[ \t]+$/, "", line)
    if (length(line) > 0) {print line; exit}
  }
')

if [ -n "$active_sink_name" ]; then
  pick_id=$(printf '%s\n' "$sinks" | awk -v name="$active_sink_name" '
    {
      if (match($0, /([0-9]+)\. ([^[]+)/, m)) {
        id=m[1]
        sname=m[2]
        gsub(/^ +| +$/, "", sname)
        if (sname == name) {print id; exit}
      }
    }
  ')
fi

# Priority fallback: HDMI (LG C2/TV) -> Bluetooth (AirPods) -> SteelSeries Game
if [ -z "$pick_id" ]; then
  pick_id=$(find_by_pattern "hdmi|lg|tv")
fi
if [ -z "$pick_id" ]; then
  pick_id=$(find_by_pattern "airpods|bluetooth")
fi
if [ -z "$pick_id" ]; then
  pick_id=$(find_by_pattern "SteelSeries Arctis 7 Game")
fi

if [ -n "$pick_id" ] && [ "$pick_id" != "$current_id" ]; then
  wpctl set-default "$pick_id" >/dev/null 2>&1 || true
  wpctl settings set-default Audio/Sink "$pick_id" >/dev/null 2>&1 || true
fi

exit 0
