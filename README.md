# thigglez_hyprland_desktop
Custom Hyprland config on CachyOS with a themed Waybar and Wofi setup.

Personal Hyprland + Waybar configuration with custom media widgets, drawer groups, and a themed Wofi launcher.

## What's inside
- Waybar config and styling
- Custom scripts (Spotify metadata/art, toggles, system metrics)
- Wofi launcher prompt styling

## Requirements
- Waybar
- Hyprland
- Wofi
- playerctl (for Spotify metadata)
- A Nerd Font or Font Awesome for icons

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

## License
Personal config; no warranty. Use at your own risk.
