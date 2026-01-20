#!/bin/sh
set -eu

if ! command -v hyprpm >/dev/null 2>&1; then
  exit 0
fi

plugin_root="${XDG_DATA_HOME:-$HOME/.local/share}/hyprpm"
need_rebuild=0

if ! find "$plugin_root" -type f -name '*.so' -print -quit 2>/dev/null | grep -q .; then
  need_rebuild=1
fi

hyprpm reload >/dev/null 2>&1 || true

if command -v hyprctl >/dev/null 2>&1; then
  i=0
  while [ "$i" -lt 20 ]; do
    if hyprctl plugins >/dev/null 2>&1; then
      break
    fi
    sleep 0.2
    i=$((i + 1))
  done

  if ! hyprctl plugins 2>/dev/null | grep -q 'hyprexpo'; then
    need_rebuild=1
  fi
  if ! hyprctl plugins 2>/dev/null | grep -q 'hyprtrails'; then
    need_rebuild=1
  fi
fi

if [ "$need_rebuild" -eq 1 ]; then
  if hyprpm --help 2>/dev/null | grep -q 'rebuild'; then
    hyprpm rebuild >/dev/null 2>&1 || true
  elif [ "${HYPRPM_AUTO_UPDATE:-0}" = "1" ]; then
    hyprpm update --force >/dev/null 2>&1 || true
  fi
  hyprpm reload >/dev/null 2>&1 || true
fi
