#!/usr/bin/env bash
set -euo pipefail

if eww active-windows | rg -q "^settings_panel$"; then
  eww close settings_panel
else
  eww open settings_panel
fi
