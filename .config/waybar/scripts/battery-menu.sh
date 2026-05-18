#!/bin/sh

STYLE="$HOME/.config/wofi/system-menu.css"
BAT_PATH="/sys/class/power_supply/BAT0"

level="$(cat "$BAT_PATH/capacity" 2>/dev/null || printf '?')"
status="$(cat "$BAT_PATH/status" 2>/dev/null || printf 'desconocido')"
current="$(printf 'Bateria: %s%% - %s' "$level" "$status")"

choice="$(
  printf '%s\n' \
    "󰁹  $current" \
    "🔌  Carga completa (0-100%)" \
    "🛡  Preservacion (40-80%)" \
    "⚖  Equilibrado (50-90%)" \
    "↺  Default TLP" |
    wofi --dmenu --allow-images --insensitive --prompt "Bateria" \
      --width 460 --height 350 --style "$STYLE" --cache-file /dev/null
)"

[ -n "$choice" ] || exit 0

case "$choice" in
  *completa*) "$HOME/scripts/battery-mode.sh" full ;;
  *Preservacion*) "$HOME/scripts/battery-mode.sh" preserve ;;
  *Equilibrado*) "$HOME/scripts/battery-mode.sh" balanced ;;
  *Default*) "$HOME/scripts/battery-mode.sh" reset ;;
  *) notify-send "Bateria" "$current" -t 3000 ;;
esac
