#!/usr/bin/env python3
import json
import re
import subprocess
import sys


def run(cmd):
    return subprocess.check_output(cmd, text=True, stderr=subprocess.DEVNULL)


def parse_device(info):
    data = {}
    for line in info.splitlines():
        if ':' not in line:
            continue
        key, val = line.split(':', 1)
        data[key.strip().lower()] = val.strip()
    return data


def main():
    try:
        devices = run(["upower", "-e"]).splitlines()
    except (OSError, subprocess.CalledProcessError):
        print(json.dumps({"text": "", "tooltip": "", "class": "ok"}))
        return 0

    entries = []
    min_pct = None

    for dev in devices:
        if "battery" not in dev:
            continue
        if "DisplayDevice" in dev:
            continue
        try:
            info = run(["upower", "-i", dev])
        except subprocess.CalledProcessError:
            continue

        data = parse_device(info)
        if data.get("present", "yes") != "yes":
            continue

        pct_raw = data.get("percentage", "").strip()
        if not pct_raw:
            continue

        match = re.search(r"(\d+)", pct_raw)
        if not match:
            continue
        pct = int(match.group(1))
        min_pct = pct if min_pct is None else min(min_pct, pct)

        name = data.get("model") or data.get("native-path") or dev.rsplit("/", 1)[-1]
        entries.append(f"{name}: {pct}%")

    if not entries:
        print(json.dumps({"text": "", "tooltip": "", "class": "ok"}))
        return 0

    if min_pct is None:
        level = "ok"
    elif min_pct <= 15:
        level = "crit"
    elif min_pct <= 30:
        level = "warn"
    else:
        level = "ok"

    tooltip = "\\n".join(entries)
    text = f"{min_pct}%"
    print(json.dumps({"text": text, "tooltip": tooltip, "class": level}))
    return 0


if __name__ == "__main__":
    sys.exit(main())
