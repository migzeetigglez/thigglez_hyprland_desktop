#!/usr/bin/env bash
set -euo pipefail

if [ "$#" -lt 1 ]; then
  exit 0
fi

"$@" >/dev/null 2>&1 &
eww close settings_panel >/dev/null 2>&1 || true
