# thigglez_hyprland_desktop
Custom Hyprland config on CachyOS with a themed Waybar and Wofi setup.

Personal Hyprland + Waybar configuration with custom media widgets, drawer groups, and a themed Wofi launcher.

## Preview
![Full desktop](full-desktop.png)
![Waybar overview](waybar.png)
![App picker](app-picker.png)
![Audio drawer](audio-drawer.png)
![System drawer](system-drawer.png)

## What's inside
- Waybar config and styling (uniform pill system + themed bar)
- Custom scripts (Spotify metadata/art, toggles, system metrics)
- Drawer groups (audio, metrics, capture)
- Recording + screenshot widgets (wf-recorder + grim/slurp)
- Wofi launcher prompt styling

## Requirements
- Waybar
- Hyprland
- Wofi
- playerctl (for Spotify metadata)
- A Nerd Font or Font Awesome for icons
- wf-recorder (screen recording)
- grim (screenshots)
- slurp (region selection)
- ImageMagick (optional tonemapping for HDR screenshots)

## Setup
1) Copy this repo into `~/.config/waybar`
2) Ensure scripts are executable:
   ```bash
   chmod +x ~/.config/waybar/scripts/*.sh ~/.config/waybar/scripts/*.py
   ```
3) Restart Waybar

## Notes
- Launcher icon uses `kirby-apps.png` in the repo.
- Spotify widget relies on `playerctl` and writes album art to `~/.cache/waybar/spotify-art`.
- Screen recordings are saved to `~/Videos/recordings/`.
- Screenshots are saved to `~/Pictures/Screenshots/`.

## License
Personal config; no warranty. Use at your own risk.
