#!/usr/bin/env python3
import json
import subprocess
import sys
from pathlib import Path

HYPRCTL = "/usr/bin/hyprctl"
POSITIONS_PATH = Path.home() / ".config" / "eww" / "popup_positions.json"


def run_json(cmd):
    out = subprocess.check_output(cmd, text=True)
    return json.loads(out)


def select_monitor(monitors, cursor, name=None):
    if name in ("<primary>", "primary"):
        for mon in monitors:
            if mon.get("focused"):
                return mon
    if name:
        for mon in monitors:
            if mon.get("name") == name:
                return mon
    for mon in monitors:
        mx = mon.get("x", 0)
        my = mon.get("y", 0)
        mw = mon.get("width", 0)
        mh = mon.get("height", 0)
        if mx <= cursor["x"] < mx + mw and my <= cursor["y"] < my + mh:
            return mon
    return monitors[0] if monitors else None


def load_positions():
    if not POSITIONS_PATH.exists():
        return {}
    try:
        with POSITIONS_PATH.open("r", encoding="utf-8") as fh:
            return json.load(fh)
    except (OSError, json.JSONDecodeError):
        return {}


def save_positions(data):
    POSITIONS_PATH.parent.mkdir(parents=True, exist_ok=True)
    with POSITIONS_PATH.open("w", encoding="utf-8") as fh:
        json.dump(data, fh, indent=2, sort_keys=True)
        fh.write("\n")


def main():
    if len(sys.argv) < 3:
        print("usage: set_popup_edge.py <window> <left|right> [monitor_name]", file=sys.stderr)
        return 2

    window = sys.argv[1]
    edge = sys.argv[2]
    monitor_name = sys.argv[3] if len(sys.argv) > 3 else None

    if edge not in ("left", "right"):
        print("edge must be left or right", file=sys.stderr)
        return 2

    try:
        cursor = run_json([HYPRCTL, "-j", "cursorpos"])
        monitors = run_json([HYPRCTL, "-j", "monitors"])
    except (subprocess.SubprocessError, json.JSONDecodeError, FileNotFoundError) as exc:
        print(f"failed to read hyprctl data: {exc}", file=sys.stderr)
        return 1

    monitor = select_monitor(monitors, cursor, monitor_name)
    if not monitor:
        print("no monitors found", file=sys.stderr)
        return 1

    mx = monitor.get("x", 0)
    mw = monitor.get("width", 0)
    if mw <= 0:
        print("invalid monitor width", file=sys.stderr)
        return 1

    ratio = (cursor["x"] - mx) / mw
    ratio = max(0.0, min(1.0, ratio))

    data = load_positions()
    per_monitor = data.setdefault("per_monitor", {})

    key = monitor.get("name") or monitor.get("model") or "default"
    per_monitor.setdefault(key, {})[window] = {
        "edge": edge,
        "ratio": ratio,
    }

    save_positions(data)
    print(f"saved {window} {edge} ratio {ratio:.4f} for {key}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
