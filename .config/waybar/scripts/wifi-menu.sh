#!/usr/bin/env bash
set -euo pipefail

MENU_PROMPT="Wi-Fi"

notify() {
  notify-send "Wi-Fi" "$1" 2>/dev/null || true
}

menu() {
  if command -v wofi >/dev/null 2>&1; then
    wofi --dmenu --insensitive --prompt "$MENU_PROMPT"
  else
    rofi -dmenu -i -p "$MENU_PROMPT"
  fi
}

password_menu() {
  local prompt="$1"
  if command -v rofi >/dev/null 2>&1; then
    rofi -dmenu -password -p "$prompt"
  else
    wofi --dmenu --password --prompt "$prompt"
  fi
}

active_ssid() {
  nmcli -t -f ACTIVE,SSID dev wifi 2>/dev/null | awk -F: '$1 == "yes" {print $2; exit}'
}

connection_exists() {
  local ssid="$1"
  nmcli -t -f NAME connection show | grep -Fxq -- "$ssid"
}

connect_saved() {
  local ssid="$1"
  if nmcli connection up id "$ssid" >/dev/null 2>&1; then
    notify "Conectado a $ssid"
  else
    notify "No pude conectar con el perfil guardado: $ssid"
  fi
}

connect_new() {
  local ssid="$1"
  local security="$2"
  local password=""

  if [[ "$security" != "--" && -n "$security" ]]; then
    password="$(password_menu "Clave para $ssid")"
    [[ -n "$password" ]] || exit 0
    if nmcli device wifi connect "$ssid" password "$password" >/dev/null 2>&1; then
      notify "Conectado a $ssid"
    else
      notify "No pude conectar a $ssid. Revisa la clave o la señal."
    fi
  else
    if nmcli device wifi connect "$ssid" >/dev/null 2>&1; then
      notify "Conectado a $ssid"
    else
      notify "No pude conectar a $ssid"
    fi
  fi
}

wifi_state="$(nmcli -g WIFI general 2>/dev/null || echo disabled)"

if [[ "$wifi_state" == "disabled" ]]; then
  choice="$(printf 'Activar Wi-Fi\nEditor avanzado\n' | menu)"
  case "$choice" in
    "Activar Wi-Fi") nmcli radio wifi on && notify "Wi-Fi activado" ;;
    "Editor avanzado") nm-connection-editor >/dev/null 2>&1 & ;;
  esac
  exit 0
fi

current="$(active_ssid)"
nmcli device wifi rescan >/dev/null 2>&1 || true

{
  if [[ -n "$current" ]]; then
    printf 'Conectado: %s\n' "$current"
    printf 'Desconectar Wi-Fi\n'
  else
    printf 'Sin conexion Wi-Fi\n'
  fi
  printf 'Refrescar redes\n'
  printf 'Desactivar Wi-Fi\n'
  printf 'Editor avanzado\n'
  printf '%s\n' "----- Redes disponibles -----"

  nmcli -t -f SSID,SECURITY,SIGNAL dev wifi list 2>/dev/null \
    | awk -F: '
      $1 != "" && !seen[$1]++ {
        lock = ($2 == "--" || $2 == "") ? "abierta" : "segura";
        printf "Red: %s | %s | %s%%\n", $1, lock, $3
      }'

  printf '%s\n' "----- Redes guardadas -----"
  nmcli -t -f NAME,TYPE connection show 2>/dev/null \
    | awk -F: '$2 == "802-11-wireless" {printf "Guardada: %s\n", $1}'
} | menu | {
  read -r choice || exit 0

  case "$choice" in
    ""|"-----"*) exit 0 ;;
    "Conectado: "*) exit 0 ;;
    "Sin conexion Wi-Fi") exit 0 ;;
    "Refrescar redes") exec "$0" ;;
    "Desconectar Wi-Fi")
      wifi_device="$(nmcli -t -f DEVICE,TYPE device status | awk -F: '$2 == "wifi" {print $1; exit}')"
      if [[ -n "${wifi_device:-}" ]]; then
        nmcli device disconnect "$wifi_device" >/dev/null 2>&1 || true
      fi
      notify "Wi-Fi desconectado"
      ;;
    "Desactivar Wi-Fi")
      nmcli radio wifi off
      notify "Wi-Fi desactivado"
      ;;
    "Editor avanzado")
      nm-connection-editor >/dev/null 2>&1 &
      ;;
    "Guardada: "*)
      ssid="${choice#Guardada: }"
      connect_saved "$ssid"
      ;;
    "Red: "*)
      entry="${choice#Red: }"
      ssid="${entry%% | *}"
      rest="${entry#* | }"
      security_label="${rest%% | *}"
      security="--"
      [[ "$security_label" == "segura" ]] && security="WPA"
      if connection_exists "$ssid"; then
        connect_saved "$ssid"
      else
        connect_new "$ssid" "$security"
      fi
      ;;
  esac
}
