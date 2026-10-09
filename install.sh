#!/bin/bash
# ============================================
#  Seducing Purple Dotfiles – Installer
# ============================================
set -e

DOTFILES="$(cd "$(dirname "$0")" && pwd)"
BACKUP="$HOME/.dotfiles-backup-$(date +%Y%m%d-%H%M%S)"

# Farben
PURPLE='\033[0;35m'
ACCENT='\033[0;95m'
NC='\033[0m'

print_header() {
    clear
    echo -e "${PURPLE}"
    echo "  ╔═══════════════════════════════════════╗"
    echo "  ║     🦄 SUCEDING PURPLE DOTFILES 🦄    ║"
    echo "  ╚═══════════════════════════════════════╝"
    echo -e "${NC}"
}

print_step() {
    echo -e "\n${ACCENT}── $1 ──${NC}\n"
}

# ============================================
#  SYSTEM-DETECTION
# ============================================
detect_gpu() {
    if lspci | grep -qi "nvidia"; then
        echo "nvidia"
    elif lspci | grep -qi "amd.*vga\|amd.*display\|radeon"; then
        echo "amd"
    else
        echo "other"
    fi
}

detect_distro() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        echo "$ID"
    else
        echo "unknown"
    fi
}

detect_timezone() {
    timedatectl show --property=Timezone --value 2>/dev/null || \
    cat /etc/timezone 2>/dev/null || \
    echo "Europe/Berlin"
}

detect_monitors() {
    hyprctl monitors -j 2>/dev/null | python3 -c "
import json, sys
try:
    data = json.load(sys.stdin)
    for m in data:
        print(f\"{m['name']}|{m['width']}x{m['height']}@{m['refreshRate']:.0f}\")
except:
    pass
" 2>/dev/null || echo "unknown|2560x1440@165"
}

# ============================================
#  USER-INPUT
# ============================================
GPU=$(detect_gpu)
DISTRO=$(detect_distro)
TZ=$(detect_timezone)
MONITORS=$(detect_monitors)
DEFAULT_MON=$(echo "$MONITORS" | head -1 | cut -d'|' -f2 | cut -d'x' -f1)

print_header

# GPU
print_step "GPU wählen"
echo "  Erkannt: $GPU"
echo ""
echo "  [1] NVIDIA  (Proprietärer Treiber, CUDA, GameMode)"
echo "  [2] AMD     (Open-Source, Mesa, Vulkan)"
echo "  [3] Intel   (Open-Source, Mesa)"
echo ""
read -p "  Auswahl [1-3]: " gpu_choice

case $gpu_choice in
    1) GPU="nvidia" ;;
    2) GPU="amd" ;;
    3) GPU="intel" ;;
    *) GPU="nvidia" ;;
esac

# Distro
print_step "Distro wählen"
echo "  Erkannt: $DISTRO"
echo ""
echo "  [1] CachyOS   (empfohlen – optimiert)"
echo "  [2] Arch      (Vanilla)"
echo "  [3] Fedora"
echo "  [4] Ubuntu/Debian"
echo ""
read -p "  Auswahl [1-4]: " distro_choice

case $distro_choice in
    1) DISTRO="cachyos" ;;
    2) DISTRO="arch" ;;
    3) DISTRO="fedora" ;;
    4) DISTRO="debian" ;;
    *) DISTRO="cachyos" ;;
esac

# Timezone
print_step "Timezone"
echo "  Erkannt: $TZ"
echo ""
read -p "  Timezone bestätigen oder ändern [Enter=$TZ]: " tz_input
[ -n "$tz_input" ] && TZ="$tz_input"

# Monitor
print_step "Monitor/Auflösung"
echo "  Erkannt:"
echo "$MONITORS" | while read -r mon; do
    [ -n "$mon" ] && echo "    $mon"
done
echo ""
echo "  [1] 2560x1440 @165Hz  (Samsung Odyssey G5)"
echo "  [2] 1920x1080 @144Hz"
echo "  [3] 1920x1080 @60Hz"
echo "  [4] 3840x2160 @144Hz  (4K)"
echo "  [5] Eigene Auflösung"
echo ""
read -p "  Auswahl [1-5]: " mon_choice

case $mon_choice in
    1) RES="2560x1440"; HZ="165" ;;
    2) RES="1920x1080"; HZ="144" ;;
    3) RES="1920x1080"; HZ="60" ;;
    4) RES="3840x2160"; HZ="144" ;;
    5)
        read -p "  Auflösung (BxH): " RES
        read -p "  Refresh Rate (Hz): " HZ
        ;;
    *) RES="2560x1440"; HZ="165" ;;
esac

MON_NAME=$(echo "$MONITORS" | head -1 | cut -d'|' -f1)
[ "$MON_NAME" = "unknown" ] && MON_NAME="DP-1"

# Shell
print_step "Shell"
echo "  [1] fish   (empfohlen)"
echo "  [2] zsh"
echo "  [3] bash"
echo ""
read -p "  Auswahl [1-3]: " shell_choice

case $shell_choice in
    1) SHELL_CFG="fish" ;;
    2) SHELL_CFG="zsh" ;;
    3) SHELL_CFG="bash" ;;
    *) SHELL_CFG="fish" ;;
esac

# Features
print_step "Features"
read -p "  GPU Overclocking aktivieren? (NVIDIA only) [J/n]: " want_oc
read -p "  RGB-Setup (OpenRGB) konfigurieren? [J/n]: " want_rgb
read -p "  Gaming-Optimierungen (GameMode, MangoHud)? [J/n]: " want_gaming

# Zusammenfassung
print_step "Zusammenfassung"
echo "  GPU:         $GPU"
echo "  Distro:      $DISTRO"
echo "  Timezone:    $TZ"
echo "  Monitor:     $MON_NAME ${RES}@${HZ}Hz"
echo "  Shell:       $SHELL_CFG"
echo "  OC:          ${want_oc:-j}"
echo "  RGB:         ${want_rgb:-j}"
echo "  Gaming:      ${want_gaming:-j}"
echo ""
read -p "  Fortfahren? [J/n]: " confirm
[ "$confirm" = "n" ] && exit 0

# ============================================
#  INSTALLATION
# ============================================
print_step "Installation starten"

# Backup
mkdir -p "$BACKUP"
echo "  📦 Backup: $BACKUP"

# Symlink-Funktion
link() {
    local src="$DOTFILES/$1"
    local dst="$HOME/$2"
    
    [ ! -e "$src" ] && return
    
    if [ -e "$dst" ] && [ ! -L "$dst" ]; then
        mkdir -p "$(dirname "$BACKUP/$2")"
        cp -r "$dst" "$BACKUP/$2" 2>/dev/null || true
        rm -rf "$dst"
    elif [ -L "$dst" ]; then
        rm "$dst"
    fi
    
    mkdir -p "$(dirname "$dst")"
    ln -sf "$src" "$dst"
    echo "  ✓ $2"
}

# Configs linken
link "hypr" ".config/hypr"
link "waybar" ".config/waybar"
link "cava" ".config/cava"
link "dunst" ".config/dunst"
link "gtk-3.0" ".config/gtk-3.0"
link "gtk-4.0" ".config/gtk-4.0"
link "ghostty" ".config/ghostty"
link "btop" ".config/btop"
link "mpv" ".config/mpv"
link "MangoHud" ".config/MangoHud"
link "starship.toml" ".config/starship.toml"

# Shell
if [ "$SHELL_CFG" = "fish" ]; then
    link "fish" ".config/fish"
fi

# Scripts installieren
echo ""
echo "  🔧 Scripts..."
mkdir -p "$HOME/.local/bin"
for script in "$DOTFILES/scripts/"*; do
    [ -f "$script" ] && [ -x "$script" ] || continue
    name=$(basename "$script")
    cp "$script" "$HOME/.local/bin/$name"
    chmod +x "$HOME/.local/bin/$name"
    echo "  ✓ $name"
done

# ============================================
#  GPU-SPECIFIC
# ============================================
print_step "GPU-Config: $GPU"

if [ "$GPU" = "nvidia" ]; then
    # NVIDIA: Hyprland Env
    sed -i 's/^LIBVA_DRIVER_NAME=.*/LIBVA_DRIVER_NAME=nvidia/' "$DOTFILES/hypr/env.lua" 2>/dev/null || true
    sed -i 's/^NVD_BACKEND=.*/NVD_BACKEND=direct/' "$DOTFILES/hypr/env.lua" 2>/dev/null || true
    sed -i 's/^GBM_BACKEND=.*/GBM_BACKEND=nvidia-drm/' "$DOTFILES/hypr/env.lua" 2>/dev/null || true
    sed -i 's/^__GLX_VENDOR_LIBRARY_NAME=.*/__GLX_VENDOR_LIBRARY_NAME=nvidia/' "$DOTFILES/hypr/env.lua" 2>/dev/null || true
    
    # NVIDIA Modules
    if ! grep -q "nvidia" /etc/mkinitcpio.conf 2>/dev/null; then
        echo "  ⚠️  NVIDIA Modules in mkinitcpio nicht konfiguriert"
        echo "     Bitte manuell hinzufügen: MODULES=(... nvidia nvidia_modeset nvidia_uvm nvidia_drm)"
    fi
    
    # OC
    if [ "${want_oc,,}" != "n" ]; then
        echo "  🔧 GPU-OC Script wird angepasst..."
        # OC bleibt wie konfiguriert
    fi
    
elif [ "$GPU" = "amd" ]; then
    # AMD: Andere Env-Vars
    sed -i 's/^LIBVA_DRIVER_NAME=.*/LIBVA_DRIVER_NAME=radeonsi/' "$DOTFILES/hypr/env.lua" 2>/dev/null || true
    sed -i '/^NVD_BACKEND=/d' "$DOTFILES/hypr/env.lua" 2>/dev/null || true
    sed -i '/^GBM_BACKEND=/d' "$DOTFILES/hypr/env.lua" 2>/dev/null || true
    sed -i '/^__GLX_VENDOR_LIBRARY_NAME=/d' "$DOTFILES/hypr/env.lua" 2>/dev/null || true
    
    # AMD GPU-OC entfernen
    rm -f "$HOME/.local/bin/gpu-oc"
    echo "  ✓ gpu-oc entfernt (AMD)"
    
elif [ "$GPU" = "intel" ]; then
    sed -i 's/^LIBVA_DRIVER_NAME=.*/LIBVA_DRIVER_NAME=iHD/' "$DOTFILES/hypr/env.lua" 2>/dev/null || true
    rm -f "$HOME/.local/bin/gpu-oc"
fi

# ============================================
#  MONITOR-CONFIG
# ============================================
print_step "Monitor-Config: ${RES}@${HZ}"

MONITOR_CFG="monitor = $MON_NAME, ${RES}@${HZ}, 0x0, 1"
echo "$MONITOR_CFG" > "$DOTFILES/hypr/monitors.conf"
echo "  ✓ monitors.conf: $MONITOR_CFG"

# Waybar Height anpassen
case "$HZ" in
    144|165|240) BAR_HEIGHT=50 ;;
    60|75|120) BAR_HEIGHT=40 ;;
    *) BAR_HEIGHT=50 ;;
esac
sed -i "s/\"height\": [0-9]*/\"height\": $BAR_HEIGHT/" "$DOTFILES/waybar/config.jsonc" 2>/dev/null || true
echo "  ✓ Waybar Height: $BAR_HEIGHT"

# ============================================
#  DISTRO-SPECIFIC
# ============================================
print_step "Distro-Config: $DISTRO"

case "$DISTRO" in
    cachyos|arch)
        # Paketliste
        cat > "$DOTFILES/packages.txt" <<'EOF'
# Core
hyprland
waybar
dunst
fish
starship
ghostty
btop
cava
mpv
gtk3
gtk4
nwg-look

# Audio
pipewire
pipewire-pulse
wireplumber
pavucontrol

# Gaming
gamemode
mangohud

# Tools
openrgb
cliphist
wl-clipboard
hyprpicker
hypridle
hyprlock
awww-git
polkit-kde-agent
network-manager-applet
blueman
xdg-desktop-portal-hyprland

# Optional
fastfetch
qalculate-gtk
thunar
EOF
        echo "  ✓ packages.txt erstellt"
        
        if command -v paru &>/dev/null; then
            echo "  📦 Installiere mit: paru -S --needed - < $DOTFILES/packages.txt"
        elif command -v yay &>/dev/null; then
            echo "  📦 Installiere mit: yay -S --needed - < $DOTFILES/packages.txt"
        else
            echo "  📦 Installiere mit: pacman -S --needed - < $DOTFILES/packages.txt"
        fi
        ;;
    
    fedora)
        cat > "$DOTFILES/packages.txt" <<'EOF'
# Fedora
hyprland
waybar
dunst
fish
starship
ghostty
btop
cava
mpv
gtk3
gtk4
pipewire
pipewire-pulseaudio
wireplumber
pavucontrol
gamemode
mangohud
openrgb
cliphist
wl-clipboard
hyprpicker
hypridle
hyprlock
EOF
        echo "  ✓ packages.txt erstellt"
        echo "  📦 Installiere mit: sudo dnf install -y \$(cat $DOTFILES/packages.txt)"
        ;;
    
    debian|ubuntu)
        echo "  ⚠️  Debian/Ubuntu: Hyprland manuell installieren"
        echo "     Siehe: https://wiki.hyprland.org/Getting-Started/Installation-by-distro"
        ;;
esac

# ============================================
#  FEATURES
# ============================================
print_step "Features"

if [ "${want_rgb,,}" != "n" ]; then
    echo "  🎨 RGB: rgb-purple Script installiert"
    echo "     Starten mit: ~/.local/bin/rgb-purple"
fi

if [ "${want_gaming,,}" != "n" ]; then
    echo "  🎮 Gaming: GameMode + MangoHud konfiguriert"
fi

# ============================================
#  FERTIG
# ============================================
print_header
echo -e "${ACCENT}  ✅ Installation abgeschlossen!${NC}"
echo ""
echo "  📋 Nächste Schritte:"
echo "     1. Pakete installieren (siehe oben)"
echo "     2. Hyprland neustarten oder Reboot"
echo "     3. Wallpaper setzen: ~/.local/bin/wallpaper-picker"
echo ""
echo "  🎨 Theme: Seducing Purple"
echo "  📁 Backup: $BACKUP"
echo ""
echo -e "${PURPLE}  🦄 Viel Spaß mit deinem Setup!${NC}"
echo ""

# Wallpapers entpacken
if [ -f "$DOTFILES/wallpapers.tar.gz" ]; then
    echo "  🖼️  Wallpapers entpacken..."
    mkdir -p "$HOME/.local/share/wallpapers"
    tar xzf "$DOTFILES/wallpapers.tar.gz" -C "$HOME/.local/share/wallpapers/"
    echo "  ✓ Wallpapers installiert"
fi
