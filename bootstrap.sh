#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$REPO_DIR/dotfiles"
PACKAGES=(hypr eww waybar)

COMMON_DEPS=(
  eww
  hyprland
  waybar
  wofi
  playerctl
  wireplumber
  pipewire
  wl-clipboard
  python
  jq
  grim
  slurp
  wf-recorder
  imagemagick
  swaync
  hyprpaper
  pavucontrol
  blueman
  ttf-jetbrains-mono
  ttf-font-awesome
  neofetch
  starship
  fish
  zsh
  bash
  kitty
  hypridle
  hyprlock
  walker
  tte
  xdg-terminal-exec
  libnotify
  brightnessctl
)

APT_DEPS=(
  eww
  waybar
  wofi
  playerctl
  wireplumber
  pipewire
  wl-clipboard
  python3
  jq
  grim
  slurp
  wf-recorder
  imagemagick
  swaync
  hyprpaper
  pavucontrol
  blueman
  fonts-jetbrains-mono
  fonts-font-awesome
  neofetch
  starship
  fish
  zsh
  bash
  kitty
  hypridle
  hyprlock
  walker
  tte
  xdg-terminal-exec
  libnotify
  brightnessctl
)

DNF_DEPS=(
  eww
  hyprland
  waybar
  wofi
  playerctl
  wireplumber
  pipewire
  wl-clipboard
  python3
  jq
  grim
  slurp
  wf-recorder
  ImageMagick
  swaync
  hyprpaper
  pavucontrol
  blueman
  jetbrains-mono-fonts
  fontawesome-fonts
  neofetch
  starship
  fish
  zsh
  bash
  kitty
  hypridle
  hyprlock
  walker
  tte
  xdg-terminal-exec
  libnotify
  brightnessctl
)

PACMAN_DEPS=("${COMMON_DEPS[@]}")

need_cmd() { command -v "$1" >/dev/null 2>&1; }

install_packages() {
  local mgr="$1"; shift
  local -a pkgs=("$@")
  local -a failed=()

  for pkg in "${pkgs[@]}"; do
    case "$mgr" in
      pacman)
        sudo pacman -S --needed --noconfirm "$pkg" || failed+=("$pkg")
        ;;
      apt)
        sudo apt-get install -y "$pkg" || failed+=("$pkg")
        ;;
      dnf)
        sudo dnf install -y "$pkg" || failed+=("$pkg")
        ;;
    esac
  done

  if [ "${#failed[@]}" -gt 0 ]; then
    echo "\nThe following packages failed to install:" >&2
    printf '  - %s\n' "${failed[@]}" >&2
    echo "Review package names for your distro and install manually." >&2
  fi
}

if [ ! -d "$DOTFILES_DIR" ]; then
  echo "dotfiles/ directory not found. Did you clone the full repo?" >&2
  exit 1
fi

if ! need_cmd stow; then
  if need_cmd pacman; then
    sudo pacman -S --needed --noconfirm stow
  elif need_cmd apt-get; then
    sudo apt-get update
    sudo apt-get install -y stow
  elif need_cmd dnf; then
    sudo dnf install -y stow
  else
    echo "No supported package manager found (pacman/apt/dnf). Install stow manually." >&2
    exit 1
  fi
fi

if need_cmd pacman; then
  install_packages pacman "${PACMAN_DEPS[@]}"
elif need_cmd apt-get; then
  sudo apt-get update
  install_packages apt "${APT_DEPS[@]}"
elif need_cmd dnf; then
  install_packages dnf "${DNF_DEPS[@]}"
else
  echo "No supported package manager found (pacman/apt/dnf)." >&2
  exit 1
fi

stow -d "$DOTFILES_DIR" -t "$HOME" "${PACKAGES[@]}"

echo "Bootstrap complete. You may need to restart Hyprland/Waybar/Eww."
