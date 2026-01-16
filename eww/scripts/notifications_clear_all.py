#!/usr/bin/env python3
import json
import subprocess
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
    entries = load_entries()
    changed = False
    for entry in entries:
        if not entry.get("dismissed"):
            entry["dismissed"] = True
            changed = True
    if changed:
        save_entries(entries)
        try:
            payload = subprocess.check_output(["/usr/bin/python3", NOTIF_SCRIPT], text=True).strip()
            subprocess.run(
                ["eww", "--config", CONFIG_DIR, "update", f"notifications={payload}"],
                check=False,
            )
        except Exception:
            pass


if __name__ == "__main__":
    main()
