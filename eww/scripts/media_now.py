#!/usr/bin/env python3
import json
import os
import subprocess
import sys
import urllib.parse
import urllib.request


def run(cmd):
    result = subprocess.run(cmd, capture_output=True, text=True)
    if result.returncode != 0:
        return None
    return result.stdout.strip()


def list_players():
    out = run(["playerctl", "-l"])
    if not out:
        return []
    return [line.strip() for line in out.splitlines() if line.strip()]


def player_status(player):
    return run(["playerctl", f"--player={player}", "status"])


def select_player():
    players = list_players()
    if not players:
        return None, None

    for status in ("Playing", "Paused"):
        for player in players:
            st = player_status(player)
            if st == status:
                return player, st

    return None, None


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
        return ""

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
        return art_file

    if not art_url.startswith("http"):
        return ""

    last_url = None
    if os.path.exists(url_file):
        try:
            with open(url_file, "r", encoding="utf-8") as fh:
                last_url = fh.read().strip()
        except OSError:
            last_url = None

    if art_url == last_url and os.path.exists(art_file):
        return art_file

    try:
        download(art_url, art_file)
        with open(url_file, "w", encoding="utf-8") as fh:
            fh.write(art_url)
        return art_file
    except Exception:
        return ""


def main():
    player, status = select_player()
    if not player:
        payload = {
            "available": False,
            "status": "Stopped",
            "artist": "",
            "title": "No media playing",
            "album": "",
            "player": "",
            "art_path": "",
        }
        sys.stdout.write(json.dumps(payload))
        return

    artist = run(["playerctl", f"--player={player}", "metadata", "--format", "{{artist}}"])
    title = run(["playerctl", f"--player={player}", "metadata", "--format", "{{title}}"])
    album = run(["playerctl", f"--player={player}", "metadata", "--format", "{{album}}"])
    art_url = run(["playerctl", f"--player={player}", "metadata", "--format", "{{mpris:artUrl}}"])

    artist = artist or "Unknown Artist"
    title = title or "Unknown Title"
    album = album or ""
    status = status or ""

    art_path = update_art(art_url)

    payload = {
        "available": True,
        "status": status,
        "artist": artist,
        "title": title,
        "album": album,
        "player": player,
        "art_path": art_path,
    }
    sys.stdout.write(json.dumps(payload))


if __name__ == "__main__":
    try:
        main()
    except Exception:
        pass
