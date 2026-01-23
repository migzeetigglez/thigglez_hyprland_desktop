#!/usr/bin/env bash
set -euo pipefail

check_err=""
updates=""
fallback_updates=""
if command -v checkupdates >/dev/null 2>&1; then
  set +e
  updates=$(checkupdates 2>/dev/null)
  check_status=$?
  set -e
  case "$check_status" in
    0) : ;;
    2) updates=""; check_err="";; # no updates
    *) check_err="checkupdates failed (sync/mirror issue)"; updates="";;
  esac
fi

fallback_updates=$(pacman -Qu 2>/dev/null || true)
if [ -z "${updates:-}" ]; then
  updates="$fallback_updates"
fi

if [ "${1:-}" = "--list" ]; then
  if [ -n "$updates" ]; then
    printf '%s\n' "$updates"
  else
    if [ -n "$check_err" ]; then
      echo "${check_err}. Try: sudo pacman -Sy"
    else
      echo "No updates (or sync required)."
    fi
  fi
  if [ -n "$check_err" ]; then
    echo
    echo "Fallback (pacman -Qu; may be stale):"
    if [ -n "$fallback_updates" ]; then
      printf '%s\n' "$fallback_updates"
    else
      echo "No updates from pacman -Qu."
    fi
  fi
  exit 0
fi

count=$(printf '%s
' "$updates" | sed '/^$/d' | wc -l | tr -d ' ')

if [ "$count" -eq 0 ]; then
  if [ -n "$check_err" ]; then
    tooltip="${check_err}\\nFallback: pacman -Qu may be stale"
    printf '{"text":" ?","tooltip":"%s","class":"warn"}\n' "$tooltip"
  else
    printf '{"text":" 0","tooltip":"No updates","class":"ok"}\n'
  fi
  exit 0
fi

preview=$(printf '%s
' "$updates" | sed -n '1,10p' | sed ':a;N;$!ba;s/\n/\\n/g')

printf '{"text":" %s","tooltip":"%s","class":"warn"}\n' "$count" "$preview"
