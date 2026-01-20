#!/usr/bin/env python3
import json
import shutil
import subprocess
import sys
from pathlib import Path


HYPRCTL = shutil.which("hyprctl") or "/usr/bin/hyprctl"
EWW = shutil.which("eww") or "/usr/bin/eww"
EWW_CONFIG = "/home/thigglez/.config/eww"
LOG_PATH = Path("/tmp/eww-popup.log")
POSITIONS_PATH = Path.home() / ".config" / "eww" / "popup_positions.json"
EDGE_MAP = {
    "media_popup": "left",
    "calendar_popup": "right",
}
OFFSETS = {
    "media_popup": -10,
    "calendar_popup": 10,
}
HEIGHTS = {
    "calendar_popup": 320,
    "media_popup": 170,
}


def log(msg):
    try:
        LOG_PATH.parent.mkdir(parents=True, exist_ok=True)
        with LOG_PATH.open("a", encoding="utf-8") as fh:
            fh.write(msg.rstrip() + "\n")
    except OSError:
        pass


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


def clamp(value, low, high):
    return max(low, min(value, high))


def load_positions():
    if not POSITIONS_PATH.exists():
        return {}
    try:
        with POSITIONS_PATH.open("r", encoding="utf-8") as fh:
            return json.load(fh)
    except (OSError, json.JSONDecodeError):
        return {}


def get_ratio(positions, window, monitor):
    name = monitor.get("name")
    model = monitor.get("model")
    per_monitor = positions.get("per_monitor", {})
    for key in (name, model, "default"):
        if not key:
            continue
        entry = per_monitor.get(key, {}).get(window)
        if entry:
            return entry.get("ratio"), entry.get("edge")
    return None, None


def main():
    if len(sys.argv) < 4:
        print("usage: open_popup_at_cursor.py <window> <width> <y> [monitor_name]", file=sys.stderr)
        return 2

    window = sys.argv[1]
    try:
        width = int(sys.argv[2])
        y_pos = int(sys.argv[3])
    except ValueError:
        print("width and y must be integers", file=sys.stderr)
        return 2

    monitor_name = sys.argv[4] if len(sys.argv) > 4 else None
    log(f"invoke window={window} width={width} y={y_pos} monitor={monitor_name or 'auto'}")
    height = HEIGHTS.get(window)
    if height is None:
        log(f"unknown window height for {window}")
        print(f"unknown window height for {window}", file=sys.stderr)
        return 2

    if not Path(EWW).exists():
        log("eww not found in PATH")
        print("eww not found", file=sys.stderr)
        return 1

    if not Path(HYPRCTL).exists():
        log("hyprctl not found; opening with default geometry")
        subprocess.run([EWW, "open", "--toggle", window], check=False)
        return 0

    try:
        cursor = run_json([HYPRCTL, "-j", "cursorpos"])
        monitors = run_json([HYPRCTL, "-j", "monitors"])
    except (subprocess.SubprocessError, json.JSONDecodeError, FileNotFoundError) as exc:
        log(f"hyprctl error: {exc}")
        print(f"failed to read hyprctl data: {exc}", file=sys.stderr)
        return 1

    monitor = select_monitor(monitors, cursor, monitor_name)
    if not monitor:
        print("no monitors found", file=sys.stderr)
        return 1

    mx = monitor.get("x", 0)
    mw = monitor.get("width", 0)

    positions = load_positions()
    ratio, stored_edge = get_ratio(positions, window, monitor)
    edge = stored_edge or EDGE_MAP.get(window, "left")
    if window == "media_popup":
        ratio = None

    if ratio is None:
        rel_x = int(cursor["x"] - mx - (width / 2))
    else:
        rel_x = int(mw * ratio)
        if edge == "right":
            rel_x -= width

    rel_x += OFFSETS.get(window, 0)
    if mw > 0:
        rel_x = clamp(rel_x, 0, max(0, mw - width))

    pos = f"{rel_x}x{y_pos}"
    size = f"{width}x{height}"
    cmd = [EWW, "--config", EWW_CONFIG, "open", "--toggle", window, "--pos", pos, "--size", size, "--anchor", "top left"]
    if monitor_name:
        if monitor_name in ("<primary>", "primary"):
            screen_name = monitor.get("model") or monitor.get("name")
        else:
            screen_name = monitor_name
        if screen_name:
            cmd.extend(["--screen", screen_name])
    log(f"calc window={window} monitor={monitor.get('name')} width={mw} ratio={ratio} edge={edge} rel_x={rel_x} pos={pos} size={size}")
    subprocess.run(cmd, check=False)
    return 0


if __name__ == "__main__":
    sys.exit(main())
