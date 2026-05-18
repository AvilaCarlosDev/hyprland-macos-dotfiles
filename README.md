# Hyprland macOS-style dotfiles

Configuracion publica para Arch Linux + Hyprland con un estilo tipo macOS:

- Hyprland con gaps, blur, bordes redondeados y animaciones suaves.
- Waybar flotante con estilo glass.
- Menu de aplicaciones con nwg-drawer.
- Menus de bateria y apagado con wofi.
- Selector de wallpaper.
- Modulo de clima para Waybar usando wttr.in.

## Capturas

Agrega aqui tus screenshots cuando quieras publicar el repositorio.

## Dependencias

Paquetes principales en Arch:

```sh
sudo pacman -S --needed hyprland waybar wofi rofi nwg-drawer nwg-dock-hyprland swaybg swaync hyprlock wl-clipboard cliphist jq curl brightnessctl pavucontrol network-manager-applet polkit-gnome
```

Opcionales:

```sh
sudo pacman -S --needed kitty nautilus papirus-icon-theme ttf-jetbrains-mono-nerd
```

Para los limites de carga de bateria se usa TLP. Si no usas TLP, puedes borrar scripts/battery-mode.sh y quitar el click de bateria en Waybar.

## Instalacion

Clona el repo y ejecuta:

```sh
./install.sh
```

El instalador hace backup de tus configs actuales antes de copiar estas.

## Clima

El script de clima usa wttr.in. Por defecto usa Caracas como ejemplo publico.

Puedes cambiarlo sin editar el script agregando variables en tu sesion o en Hyprland:

```conf
env = WEATHER_LOCATION,Caracas,Venezuela
env = WEATHER_LOCATION_PRETTY,Caracas, VE
```

Usa el formato que entiende wttr.in, por ejemplo Madrid,Spain o Buenos+Aires,Argentina.

## Seguridad

Este repo esta pensado para ser publico. No debe contener:

- claves SSH
- tokens o API keys
- archivos .env
- configuraciones de WiFi/VPN
- caches, logs o historiales
- backups completos del home

Antes de publicar, ejecuta:

```sh
rg -n --hidden -i "token|api[_-]?key|secret|password|passwd|bearer|authorization|private[_-]?key|ssh|github|ghp_|sk-|BEGIN .*PRIVATE KEY|webhook|vpn|wifi|ssid" .
```

Si aparece algo sensible, no publiques hasta limpiarlo.
