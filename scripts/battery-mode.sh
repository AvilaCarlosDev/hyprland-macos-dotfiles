#!/bin/bash
# Battery Mode Selector - ThinkPad E14
# Cambia umbrales de carga de TLP

MODE=$1

case $MODE in
  full)
    # Carga completa (0-100%)
    sudo bash -c 'printf "%s\n" "START_CHARGE_THRESH_BAT0=0" "STOP_CHARGE_THRESH_BAT0=100" > /etc/tlp.d/99-battery-override.conf'
    notify-send "🔋 Batería" "Modo: CARGA COMPLETA (0-100%)" -t 3000
    ;;
  preserve)
    # Preservación (40-80%)
    sudo bash -c 'printf "%s\n" "START_CHARGE_THRESH_BAT0=40" "STOP_CHARGE_THRESH_BAT0=80" > /etc/tlp.d/99-battery-override.conf'
    notify-send "🔋 Batería" "Modo: PRESERVACIÓN (40-80%)" -t 3000
    ;;
  balanced)
    # Equilibrado (50-90%)
    sudo bash -c 'printf "%s\n" "START_CHARGE_THRESH_BAT0=50" "STOP_CHARGE_THRESH_BAT0=90" > /etc/tlp.d/99-battery-override.conf'
    notify-send "🔋 Batería" "Modo: EQUILIBRADO (50-90%)" -t 3000
    ;;
  reset)
    # Eliminar configuración personalizada
    sudo rm -f /etc/tlp.d/99-battery-override.conf
    notify-send "🔋 Batería" "Modo: DEFAULT TLP" -t 3000
    ;;
  *)
    # Mostrar menú con wofi
    selection="$(echo "⚡ Modo de Carga
full,🔌 Carga Completa (0-100%)
preserve,🛡️ Preservación (40-80%)
balanced,⚖️ Equilibrado (50-90%)
reset,🔄 Default TLP" | wofi --dmenu --prompt "Selecciona modo de batería:" | cut -d',' -f1)"
    [ -n "$selection" ] || exit 0
    "$0" "$selection"
    exit
    ;;
esac

# Aplicar cambios
sudo tlp start 2>/dev/null

# Notificar nivel actual
sleep 2
LEVEL=$(cat /sys/class/power_supply/BAT0/capacity 2>/dev/null)
STATUS=$(cat /sys/class/power_supply/BAT0/status 2>/dev/null)
notify-send "🔋 Estado Actual" "Nivel: ${LEVEL}%\nEstado: ${STATUS}" -t 5000
