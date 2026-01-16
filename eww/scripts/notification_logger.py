#!/usr/bin/env python3
import json
import time
from pathlib import Path

import subprocess

LOG_PATH = Path.home() / ".config" / "eww" / "notifications_log.json"
MAX_AGE = 3600
MAX_ENTRIES = 200


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


def prune(entries, now):
    fresh = [entry for entry in entries if now - entry.get("ts", 0) <= MAX_AGE]
    return fresh[:MAX_ENTRIES]


def urgency_label(value):
    try:
        value = int(value)
    except (TypeError, ValueError):
        return "normal"
    if value <= 0:
        return "low"
    if value == 1:
        return "normal"
    return "critical"


def parse_monitor_line(line):
    line = line.strip()
    if line.startswith("string "):
        return ("string", line[len("string "):].strip().strip('"'))
    if line.startswith("variant") and "string" in line:
        value = line.split("string", 1)[1].strip().strip('"')
        return ("string", value)
    if line.startswith("uint32 "):
        return ("uint32", line[len("uint32 "):].strip())
    if line.startswith("int32 "):
        return ("int32", line[len("int32 "):].strip())
    if line.startswith("byte "):
        return ("byte", line[len("byte "):].strip())
    if line.startswith("member=") and "Notify" in line:
        return ("notify", None)
    return (None, None)


def run_monitor():
    cmd = [
        "dbus-monitor",
        "--session",
        "type='method_call',interface='org.freedesktop.Notifications',member='Notify'",
    ]
    return subprocess.Popen(
        cmd,
        stdout=subprocess.PIPE,
        stderr=subprocess.DEVNULL,
        text=True,
        bufsize=1,
    )


def main():
    proc = run_monitor()
    if not proc.stdout:
        return

    current = None
    strings = []
    urgency = None
    in_notify = False
    pending_urgency = False
    pending_desktop = False

    for raw in proc.stdout:
        line = raw.strip()
        if "member=Notify" in line:
            in_notify = True
            current = {"app": "Unknown", "summary": "(no title)", "body": ""}
            continue

        if not in_notify or current is None:
            continue

        if line.startswith('string "urgency"'):
            pending_urgency = True
            continue
        if line.startswith('string "desktop-entry"'):
            pending_desktop = True
            continue

        kind, value = parse_monitor_line(line)
        if kind == "string":
            strings.append(value)
            # Order: app_name, app_icon, summary, body
            if len(strings) == 1:
                current["app"] = value or "Unknown"
            elif len(strings) == 3:
                current["summary"] = value or "(no title)"
            elif len(strings) == 4:
                current["body"] = value or ""
            if pending_desktop:
                current["desktop_entry"] = value
                if current.get("app") in ("Unknown", "", None):
                    current["app"] = value
                pending_desktop = False
        elif kind == "byte" and pending_urgency:
            try:
                urgency = int(value, 0)
            except ValueError:
                urgency = None
            pending_urgency = False
        elif kind == "int32" and in_notify:
            current["urgency"] = urgency_label(urgency)
            now = time.time()
            current["ts"] = now
            current["id"] = str(int(now * 1000))
            entries = load_entries()
            entries.insert(0, current)
            entries = prune(entries, now)
            save_entries(entries)
            current = None
            strings = []
            urgency = None
            in_notify = False
            pending_urgency = False
            pending_desktop = False


if __name__ == "__main__":
    main()
