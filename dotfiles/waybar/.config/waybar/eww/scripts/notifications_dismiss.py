#!/usr/bin/env python3
import json
import subprocess
import sys
from pathlib import Path

LOG_PATH = Path.home() / ".config" / "eww" / "notifications_log.json"
CONFIG_DIR = "/home/thigglez/.config/eww"
NOTIF_SCRIPT = "/home/thigglez/.config/eww/scripts/notifications_for_eww.py"


def load_entries():
    if not LOG_PATH.exists():
        return []
    try:
        with LOG_PATH.open("r", encoding="utf-8") as fh:
            return json.load(fh)
    except (OSError, json.JSONDecodeError):
        return []


def save_entries(entries):
    LOG_PATH.parent.mkdir(parents=True, exist_ok=True)
    with LOG_PATH.open("w", encoding="utf-8") as fh:
        json.dump(entries, fh)
        fh.write("\n")


def main():
    if len(sys.argv) < 2:
        return 1
    target = sys.argv[1]
    entries = load_entries()
    changed = False
    for entry in entries:
        entry_id = entry.get("id")
        entry_ts = entry.get("ts")
        fallback_id = str(int(entry_ts * 1000)) if entry_ts else None
        if str(entry_id) == target or (fallback_id and fallback_id == target):
            entry["dismissed"] = True
            changed = True
            break
    if changed:
        save_entries(entries)
        try:
            payload = subprocess.check_output([sys.executable, NOTIF_SCRIPT], text=True).strip()
            subprocess.run(
                ["eww", "--config", CONFIG_DIR, "update", f"notifications={payload}"],
                check=False,
            )
        except Exception:
            pass
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
