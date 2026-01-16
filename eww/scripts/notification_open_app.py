#!/usr/bin/env python3
import json
import re
import shutil
import subprocess
import sys
from pathlib import Path

HYPRCTL = shutil.which("hyprctl") or "/usr/bin/hyprctl"


def main():
    if len(sys.argv) < 2:
        return 1

    desktop_entry = sys.argv[1]
    app_name = sys.argv[2] if len(sys.argv) > 2 else ""

    gtk_launch = shutil.which("gtk-launch")
    gio_launch = shutil.which("gio")

    # Try to focus an existing window first (Hyprland).
    if Path(HYPRCTL).exists():
        try:
            out = subprocess.check_output([HYPRCTL, "-j", "clients"], text=True)
            clients = json.loads(out)
            targets = set()
            if desktop_entry:
                entry = desktop_entry.lower()
                entry = entry[:-8] if entry.endswith(".desktop") else entry
                targets.update([entry, desktop_entry.lower(), entry.split(".")[-1]])
                segments = [seg for seg in re.split(r"[.-]+", entry) if seg]
                targets.update(segments)
                if segments and segments[0] in {"com", "org", "net", "io", "app"}:
                    targets.update(segments[1:])
            if app_name:
                targets.add(app_name.lower())
            targets = [t for t in targets if t]
            for client in clients:
                cls = (client.get("class") or "").lower()
                icls = (client.get("initialClass") or "").lower()
                title = (client.get("title") or "").lower()
                ititle = (client.get("initialTitle") or "").lower()
                appid = (client.get("app") or "").lower()
                if targets and any(
                    t in cls or t in icls or t in title or t in ititle or t in appid for t in targets
                ):
                    address = client.get("address")
                    workspace = client.get("workspace") or {}
                    workspace_id = workspace.get("id")
                    workspace_name = workspace.get("name")
                    if workspace_id is not None:
                        subprocess.run([HYPRCTL, "dispatch", "workspace", str(workspace_id)], check=False)
                    elif workspace_name:
                        subprocess.run([HYPRCTL, "dispatch", "workspace", str(workspace_name)], check=False)
                    if address:
                        subprocess.run(
                            [HYPRCTL, "dispatch", "focuswindow", f"address:{address}"],
                            check=False,
                        )
                        return 0
        except Exception:
            pass

    if desktop_entry and gtk_launch:
        subprocess.Popen([gtk_launch, desktop_entry])
        return 0

    if desktop_entry and gio_launch:
        subprocess.Popen([gio_launch, "launch", desktop_entry])
        return 0

    if app_name and gtk_launch:
        subprocess.Popen([gtk_launch, app_name])
        return 0

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
