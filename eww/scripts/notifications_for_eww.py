#!/usr/bin/env python3
import json
import time
from pathlib import Path

LOG_PATH = Path.home() / ".config" / "eww" / "notifications_log.json"
MAX_AGE = 3600


def load_entries():
    if not LOG_PATH.exists():
        return []
    try:
        with LOG_PATH.open("r", encoding="utf-8") as fh:
            return json.load(fh)
    except (OSError, json.JSONDecodeError):
        return []


def age_label(seconds):
    if seconds < 60:
        return "just now"
    minutes = int(seconds / 60)
    if minutes < 60:
        return f"{minutes}m ago"
    hours = int(minutes / 60)
    return f"{hours}h ago"


def main():
    now = time.time()
    entries = []
    for entry in load_entries():
        ts = entry.get("ts", 0)
        if now - ts > MAX_AGE:
            continue
        if entry.get("dismissed"):
            continue
        entry_id = entry.get("id") or (str(int(ts * 1000)) if ts else "")
        desktop_entry = entry.get("desktop_entry", "")
        app = entry.get("app") or desktop_entry or "Unknown"
        entries.append({
            "id": str(entry_id),
            "summary": entry.get("summary", "(no title)"),
            "body": entry.get("body", ""),
            "app": app,
            "urgency": entry.get("urgency", "normal"),
            "age": age_label(max(0, now - ts)),
            "desktop_entry": desktop_entry,
        })

    sysout = json.dumps(entries)
    print(sysout)


if __name__ == "__main__":
    main()
