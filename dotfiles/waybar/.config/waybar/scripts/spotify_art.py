#!/usr/bin/env python3
import os
import subprocess
import sys
import urllib.parse
import urllib.request

PLAYER = "spotify,spotifyd"


def run_playerctl(args):
    cmd = ["playerctl", f"--player={PLAYER}"] + args
    result = subprocess.run(cmd, capture_output=True, text=True)
    if result.returncode != 0:
        return None
    return result.stdout.strip()


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


def main():
    art_url = run_playerctl(["metadata", "--format", "{{mpris:artUrl}}"])
    if not art_url:
        sys.stdout.write("\n")
        return

    if art_url.startswith("file://"):
        path = urllib.parse.unquote(art_url[len("file://"):])
        if os.path.exists(path):
            sys.stdout.write(path)
        else:
            sys.stdout.write("\n")
        return

    if not art_url.startswith("http"):
        sys.stdout.write("\n")
        return

    cache = cache_dir()
    url_file = os.path.join(cache, "spotify-art-url")
    art_file = os.path.join(cache, "spotify-art")

    last_url = None
    if os.path.exists(url_file):
        try:
            with open(url_file, "r", encoding="utf-8") as fh:
                last_url = fh.read().strip()
        except OSError:
            last_url = None

    if art_url != last_url or not os.path.exists(art_file):
        try:
            download(art_url, art_file)
            with open(url_file, "w", encoding="utf-8") as fh:
                fh.write(art_url)
        except Exception:
            if os.path.exists(art_file):
                sys.stdout.write(art_file)
            else:
                sys.stdout.write("\n")
            return

    sys.stdout.write(art_file)


if __name__ == "__main__":
    try:
        main()
    except Exception:
        pass
