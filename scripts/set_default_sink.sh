#!/usr/bin/env bash
set -euo pipefail

sink_name="alsa_output.usb-SteelSeries_SteelSeries_Arctis_7-00.stereo-game"

if command -v wpctl >/dev/null 2>&1; then
  wpctl set-default "$sink_name" 2>/dev/null || true
elif command -v pactl >/dev/null 2>&1; then
  pactl set-default-sink "$sink_name" 2>/dev/null || true
fi

# Emit empty output so the module can be hidden.
printf ''
