#!/usr/bin/env python3
import json
import os
import subprocess
import sys
import urllib.parse
import urllib.request


def run_playerctl(player, args):
    cmd = ["playerctl", f"--player={player}"] + args
    result = subprocess.run(cmd, capture_output=True, text=True)
    if result.returncode != 0:
        return None
    return result.stdout.strip()


def list_players():
    result = subprocess.run(["playerctl", "-l"], capture_output=True, text=True)
    if result.returncode != 0:
        return []
    return [line.strip() for line in result.stdout.splitlines() if line.strip()]


def player_status(player):
    return run_playerctl(player, ["status"])


def select_player():
    players = list_players()
    if not players:
        return None, None

    preferred = [
        "spotify",
        "com.spotify.Client",
        "spotify-player",
    ]
    candidates = []
    for player in players:
        lower = player.lower()
        if any(key in lower for key in preferred):
            candidates.append(player)
    if not candidates:
        return None, None

    for status in ("Playing", "Paused"):
        for player in candidates:
            st = player_status(player)
            if st == status:
                return player, st

    return None, None


def format_time(seconds):
    if seconds < 0:
        seconds = 0
    total = int(seconds)
    hours = total // 3600
    minutes = (total % 3600) // 60
    secs = total % 60
    if hours > 0:
        return f"{hours}:{minutes:02d}:{secs:02d}"
    return f"{minutes}:{secs:02d}"


def cache_dir():
    base = os.environ.get("XDG_CACHE_HOME", os.path.join(os.path.expanduser("~"), ".cache"))
    path = os.path.join(base, "waybar")
    os.makedirs(path, exist_ok=True)
    return path


def download(url, dest):
    tmp = dest + ".tmp"
    with urllib.request.urlopen(url, timeout=5) as resp:
        with open(tmp, "wb") as fh:
            fh.write(resp.read())
    os.replace(tmp, dest)


def update_art(art_url):
    if not art_url:
        return

    cache = cache_dir()
    url_file = os.path.join(cache, "spotify-art-url")
    art_file = os.path.join(cache, "spotify-art")

    if art_url.startswith("file://"):
        path = urllib.parse.unquote(art_url[len("file://"):])
        if os.path.exists(path):
            if path != art_file:
                try:
                    if os.path.islink(art_file) or os.path.exists(art_file):
                        os.remove(art_file)
                    os.symlink(path, art_file)
                except OSError:
                    pass
        return

    if not art_url.startswith("http"):
        return

    last_url = None
    if os.path.exists(url_file):
        try:
            with open(url_file, "r", encoding="utf-8") as fh:
                last_url = fh.read().strip()
        except OSError:
            last_url = None

    if art_url == last_url and os.path.exists(art_file):
        return

    try:
        download(art_url, art_file)
        with open(url_file, "w", encoding="utf-8") as fh:
            fh.write(art_url)
    except Exception:
        pass


def build_bar(position_sec, length_sec, width=12):
    if length_sec <= 0:
        return "[------------]"
    ratio = max(0.0, min(1.0, position_sec / length_sec))
    filled = int(ratio * width)
    return "[" + ("#" * filled) + ("-" * (width - filled)) + "]"


def main():
    player, status = select_player()
    if not player or not status:
        sys.stdout.write(json.dumps({"text": ""}))
        return

    status_lower = status.lower()
    if status_lower == "stopped":
        sys.stdout.write(json.dumps({"text": ""}))
        return

    artist = run_playerctl(player, ["metadata", "--format", "{{artist}}"])
    title = run_playerctl(player, ["metadata", "--format", "{{title}}"])
    album = run_playerctl(player, ["metadata", "--format", "{{album}}"])
    art_url = run_playerctl(player, ["metadata", "--format", "{{mpris:artUrl}}"])

    length_us = run_playerctl(player, ["metadata", "--format", "{{mpris:length}}"])
    position = run_playerctl(player, ["position"])

    try:
        length_sec = float(length_us) / 1_000_000 if length_us else 0.0
    except ValueError:
        length_sec = 0.0

    try:
        position_sec = float(position) if position else 0.0
    except ValueError:
        position_sec = 0.0

    artist = artist or "Unknown Artist"
    title = title or "Unknown Title"

    update_art(art_url)

    bar = build_bar(position_sec, length_sec)
    time_text = f"{format_time(position_sec)}/{format_time(length_sec)}"
    text = f"{artist} - {title} {bar} {time_text}"

    tooltip = album or "Unknown Album"
    tooltip = f"{tooltip} ({player})"

    payload = {
        "text": text,
        "class": status_lower,
        "tooltip": tooltip
    }
    sys.stdout.write(json.dumps(payload))


if __name__ == "__main__":
    try:
        main()
    except Exception:
        sys.stdout.write(json.dumps({"text": ""}))
