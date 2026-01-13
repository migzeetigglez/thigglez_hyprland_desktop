#!/usr/bin/env bash
set -euo pipefail

iface=${1:-}
if [ -z "$iface" ]; then
  iface=$(ip route show default 2>/dev/null | awk '{print $5; exit}')
fi

if [ -z "$iface" ] || [ ! -d "/sys/class/net/$iface" ]; then
  printf '{"text":" --","tooltip":"No default interface","class":"off"}\n'
  exit 0
fi

rx=$(cat "/sys/class/net/$iface/statistics/rx_bytes")
tx=$(cat "/sys/class/net/$iface/statistics/tx_bytes")
now=$(date +%s)
state="/tmp/waybar-net-${iface}.state"

if [ -f "$state" ]; then
  read -r last_rx last_tx last_t < "$state" || true
else
  last_rx=$rx
  last_tx=$tx
  last_t=$now
fi

echo "$rx $tx $now" > "$state"

interval=$((now - last_t))
if [ "$interval" -le 0 ]; then
  interval=1
fi

rx_rate=$(( (rx - last_rx) / interval ))
tx_rate=$(( (tx - last_tx) / interval ))

human() {
  local b=$1
  local out
  if [ "$b" -lt 1024 ]; then
    out="${b}B/s"
  elif [ "$b" -lt 1048576 ]; then
    out=$(awk -v v="$b" 'BEGIN { printf "%.1fK/s", v/1024 }')
  elif [ "$b" -lt 1073741824 ]; then
    out=$(awk -v v="$b" 'BEGIN { printf "%.1fM/s", v/1048576 }')
  else
    out=$(awk -v v="$b" 'BEGIN { printf "%.1fG/s", v/1073741824 }')
  fi
  printf '%s' "$out"
}

rx_h=$(human "$rx_rate")
tx_h=$(human "$tx_rate")

printf '{"text":" ↓%s ↑%s","tooltip":"%s","class":"on"}\n' "$rx_h" "$tx_h" "$iface"
