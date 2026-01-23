#!/usr/bin/env python3
import json
import shutil
import subprocess
import sys
from pathlib import Path

MAKOCTL = shutil.which("makoctl") or "/usr/bin/makoctl"


def run(cmd):
    try:
        result = subprocess.run(cmd, capture_output=True, text=True)
    except OSError:
        return None
    if result.returncode != 0:
        return None
    return result.stdout


def parse(output):
    entries = []
    current = None
    if not output:
        return entries

    for line in output.splitlines():
        if line.startswith("Notification "):
            if current:
                entries.append(current)
            header = line[len("Notification "):]
            if ": " in header:
                ident, summary = header.split(": ", 1)
            else:
                ident, summary = header, ""
            current = {
                "id": ident.strip(),
                "summary": summary.strip() or "(no title)",
                "app": "",
                "urgency": "normal",
            }
            continue

        if current is None:
            continue

        if line.startswith("  Desktop entry:"):
            current["app"] = line.split(":", 1)[1].strip()
        elif line.startswith("  Urgency:"):
            current["urgency"] = line.split(":", 1)[1].strip()
        elif line.startswith("  App:"):
            current["app"] = line.split(":", 1)[1].strip()

    if current:
        entries.append(current)
    return entries


def main():
    if not Path(MAKOCTL).exists():
        sys.stdout.write("[]")
        return

    active = parse(run([MAKOCTL, "list"]))
    history = parse(run([MAKOCTL, "history"]))

    seen = set()
    merged = []
    for entry in active + history:
        ident = entry.get("id")
        if not ident or ident in seen:
            continue
        seen.add(ident)
        if not entry.get("app"):
            entry["app"] = "Unknown"
        merged.append(entry)

    merged = merged[:50]
    sys.stdout.write(json.dumps(merged))


if __name__ == "__main__":
    main()
