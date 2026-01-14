# thigglez_hyprland_desktop
Custom Hyprland config on CachyOS with a themed Waybar and Wofi setup.

Personal Hyprland + Waybar configuration with custom media widgets, drawer groups, and a themed Wofi launcher.

## Preview
![Full desktop](full-desktop.png)
Full desktop: overall layout, pill system, and muted pastel bar theme.
![Waybar overview](waybar.png)
Waybar overview: active workspaces, media, and system status at a glance.
![App picker](app-picker.png)
App picker: Wofi launcher with the custom prompt styling and theming.
![Audio drawer](audio-drawer.png)
Audio drawer: quick access to output, volume slider, mute, and mic controls.
![System drawer](system-drawer.png)
System drawer: power/metrics tray with CPU, memory, temperature, and toggles.
![Kitty + Fish](kitty-fish.png)
Terminal: Kitty paired with Fish shell prompt styling and matching theme.

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
