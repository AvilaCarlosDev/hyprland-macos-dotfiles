#!/usr/bin/env bash
set -euo pipefail

repo_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
backup_dir="$HOME/.dotfiles-hyprland-backup-$(date +%Y%m%d-%H%M%S)"

echo "Creating backup in: $backup_dir"
mkdir -p "$backup_dir/.config"

for dir in hypr waybar wofi rofi; do
  if [ -e "$HOME/.config/$dir" ]; then
    cp -a "$HOME/.config/$dir" "$backup_dir/.config/"
  fi
done

if [ -e "$HOME/scripts" ]; then
  cp -a "$HOME/scripts" "$backup_dir/"
fi

if [ -e "$HOME/.local/share/applications" ]; then
  mkdir -p "$backup_dir/.local/share"
  cp -a "$HOME/.local/share/applications" "$backup_dir/.local/share/"
fi

echo "Installing dotfiles..."
mkdir -p "$HOME/.config"
cp -a "$repo_dir/.config/hypr" "$HOME/.config/"
cp -a "$repo_dir/.config/waybar" "$HOME/.config/"
cp -a "$repo_dir/.config/wofi" "$HOME/.config/"
cp -a "$repo_dir/.config/rofi" "$HOME/.config/"

mkdir -p "$HOME/.local/share"
cp -a "$repo_dir/.local/share/applications" "$HOME/.local/share/"

mkdir -p "$HOME/scripts"
cp -a "$repo_dir/scripts/." "$HOME/scripts/"

chmod +x "$HOME/.config/waybar/scripts/"*.sh 2>/dev/null || true
chmod +x "$HOME/.config/hypr/scripts/"*.sh 2>/dev/null || true
chmod +x "$HOME/scripts/"*.sh 2>/dev/null || true

echo "Done."
echo "Backup saved in: $backup_dir"
echo "Restart your Hyprland session or run: hyprctl reload"
