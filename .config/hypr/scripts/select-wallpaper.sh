#!/bin/bash
set -euo pipefail

WALLPAPER_DIR="$HOME/wallpaper"
THUMB_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/wallpaper-selector/thumbs"
ROFI_THEME="${ROFI_THEME:-}"

mkdir -p "$THUMB_DIR"

mapfile -t WALLPAPERS < <(
    find "$WALLPAPER_DIR" -type f \
        \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.webp" \) |
        sort
)

if [ "${#WALLPAPERS[@]}" -eq 0 ]; then
    notify-send "Wallpaper" "No se encontraron wallpapers en $WALLPAPER_DIR" 2>/dev/null || true
    exit 0
fi

make_thumb() {
    local source="$1"
    local hash
    hash="$(printf '%s' "$source" | sha256sum | awk '{print $1}')"
    local thumb="$THUMB_DIR/$hash.png"

    if [ ! -s "$thumb" ] || [ "$source" -nt "$thumb" ]; then
        magick "$source" -auto-orient -thumbnail 256x144^ -gravity center -extent 256x144 "$thumb" 2>/dev/null || {
            printf '%s\n' "$source"
            return
        }
    fi

    printf '%s\n' "$thumb"
}

MENU_ITEMS=()
for wallpaper in "${WALLPAPERS[@]}"; do
    name="$(basename "$wallpaper")"
    thumb="$(make_thumb "$wallpaper")"
    MENU_ITEMS+=("$name\x00icon\x1f$thumb")
done

ROFI_ARGS=(
    -no-config
    -dmenu
    -i
    -show-icons
    -p "Seleccionar Wallpaper"
    -theme-str 'window { width: 60%; }'
    -theme-str 'listview { lines: 5; }'
    -theme-str 'element { padding: 8px; }'
    -theme-str 'element-icon { size: 128px; }'
)
if [ -n "$ROFI_THEME" ]; then
    ROFI_ARGS+=(-theme "$ROFI_THEME")
fi

SELECTION="$(printf '%b\n' "${MENU_ITEMS[@]}" | rofi "${ROFI_ARGS[@]}")"

if [ -z "$SELECTION" ]; then
    exit 0
fi

SELECTED_PATH=""
for wallpaper in "${WALLPAPERS[@]}"; do
    if [ "$(basename "$wallpaper")" = "$SELECTION" ]; then
        SELECTED_PATH="$wallpaper"
        break
    fi
done

if [ -z "$SELECTED_PATH" ]; then
    notify-send "Wallpaper" "No pude encontrar: $SELECTION" 2>/dev/null || true
    exit 1
fi

pkill swaybg 2>/dev/null || true
swaybg -i "$SELECTED_PATH" -m fill &

echo "$SELECTED_PATH" > "$HOME/.config/hypr/current_wallpaper"
notify-send "Wallpaper" "Fondo cambiado a: $SELECTION" -i "$SELECTED_PATH" 2>/dev/null || true
