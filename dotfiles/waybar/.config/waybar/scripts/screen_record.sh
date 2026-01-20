#!/usr/bin/env bash
set -euo pipefail

if pgrep -x wf-recorder >/dev/null 2>&1; then
  printf '{"text":" REC","class":"recording","tooltip":"Stop recording"}\n'
else
  printf '{"text":"","class":"idle","tooltip":"Start recording"}\n'
fi
