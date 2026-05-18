#!/bin/sh

STYLE="$HOME/.config/wofi/system-menu.css"

choice="$(
  printf '%s\n' \
    "  Bloquear pantalla" \
    "󰤄  Suspender" \
    "󰜉  Reiniciar" \
    "⏻  Apagar" \
    "󰍃  Cerrar sesion" |
    wofi --dmenu --allow-images --insensitive --prompt "Energia" \
      --width 420 --height 330 --style "$STYLE" --cache-file /dev/null
)"

[ -n "$choice" ] || exit 0

case "$choice" in
  *Bloquear*) hyprlock -l 2>/dev/null || loginctl lock-session ;;
  *Suspender*) systemctl suspend ;;
  *Reiniciar*) systemctl reboot ;;
  *Apagar*) systemctl poweroff ;;
  *sesion*) hyprctl dispatch exit ;;
esac
