#!/usr/bin/env bash
set -euo pipefail

EWW=/usr/bin/eww
CONFIG=/home/thigglez/.config/eww
PID_FILE=/tmp/eww-volume-osd.pid
SINK='@DEFAULT_AUDIO_SINK@'
OSD_NAME="volume_osd"

action="${1:-show}"
case "$action" in
  up)
    wpctl set-volume -l 1.0 "$SINK" 5%+
    ;;
  down)
    wpctl set-volume -l 1.0 "$SINK" 5%-
    ;;
  mute)
    wpctl set-mute "$SINK" toggle
    ;;
  show)
    ;;
  *)
    exit 1
    ;;
esac

vol_line=$(wpctl get-volume "$SINK" 2>/dev/null || true)
vol=$(printf '%s' "$vol_line" | awk '{print $2}')
muted=false
if printf '%s' "$vol_line" | grep -q "MUTED"; then
  muted=true
fi
if [ -z "$vol" ]; then
  vol="0"
fi

percent=$(python3 - <<PY
v=float("$vol")
print(int(round(v*100)))
PY
)

$EWW --config "$CONFIG" update volume_percent="$percent" volume_muted="$muted"
if ! $EWW --config "$CONFIG" active-windows | awk -F': ' '$2 == "'"$OSD_NAME"'" {found=1} END {exit !found}'; then
  $EWW --config "$CONFIG" open "$OSD_NAME"
fi

if [ -f "$PID_FILE" ]; then
  old=$(cat "$PID_FILE" 2>/dev/null || true)
  if [ -n "$old" ] && kill -0 "$old" 2>/dev/null; then
    kill "$old" 2>/dev/null || true
  fi
fi

(sleep 1.2; $EWW --config "$CONFIG" close volume_osd) &
echo $! > "$PID_FILE"
