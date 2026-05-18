#!/bin/bash

# Directorio de wallpapers
WALLPAPER_DIR="$HOME/wallpaper"

# Crear lista de wallpapers (solo jpg/jpeg/png)
mapfile -t WALLPAPERS < <(find "$WALLPAPER_DIR" -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" \) | sort)

# Mostrar menú con rofi y obtener selección.
# Usamos -no-config para evitar errores por themes/config corruptos.
SELECTION=$(printf '%s\n' "${WALLPAPERS[@]##*/}" | rofi -no-config -dmenu -i -p "Seleccionar Wallpaper")

# Si se hizo una selección
if [ -n "$SELECTION" ]; then
    # Encontrar la ruta completa
    SELECTED_PATH=$(printf '%s\n' "${WALLPAPERS[@]}" | grep "$SELECTION")
    
    if [ -n "$SELECTED_PATH" ]; then
        # Matar cualquier instancia previa de swaybg
        pkill swaybg 2>/dev/null
        
        # Establecer el nuevo fondo con swaybg
        swaybg -i "$SELECTED_PATH" -m fill &
        
        # Guardar la selección para persistencia
        echo "$SELECTED_PATH" > ~/.config/hypr/current_wallpaper
        
        # Notificar éxito
        notify-send "Wallpaper" "Fondo cambiado a: $SELECTION" -i "$SELECTED_PATH" 2>/dev/null || true
    fi
fi
