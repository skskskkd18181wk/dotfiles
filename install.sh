#!/bin/bash
# Seducing Purple Dotfiles Installer
set -e

DOTFILES="$(cd "$(dirname "$0")" && pwd)"
BACKUP="$HOME/.dotfiles-backup-$(date +%Y%m%d)"

echo "🦄 Seducing Purple Dotfiles Installer"
echo "======================================"

# Backup
mkdir -p "$BACKUP"
echo "📦 Backing up existing configs to $BACKUP"

# Symlink-Funktion
link() {
    local src="$DOTFILES/$1"
    local dst="$HOME/$2"
    
    if [ -e "$dst" ] && [ ! -L "$dst" ]; then
        mv "$dst" "$BACKUP/"
        echo "  ↳ backed up $2"
    elif [ -L "$dst" ]; then
        rm "$dst"
    fi
    
    mkdir -p "$(dirname "$dst")"
    ln -sf "$src" "$dst"
    echo "  ✓ $2"
}

echo ""
echo "📁 Linking configs..."

# Hyprland
link "hypr" ".config/hypr"

# Waybar
link "waybar" ".config/waybar"

# Cava
link "cava" ".config/cava"

# Dunst
link "dunst" ".config/dunst"

# Fish
link "fish" ".config/fish"

# GTK
link "gtk-3.0" ".config/gtk-3.0"
link "gtk-4.0" ".config/gtk-4.0"

# Ghostty
link "ghostty" ".config/ghostty"

# btop
link "btop" ".config/btop"

# mpv
link "mpv" ".config/mpv"

# MangoHud
link "MangoHud" ".config/MangoHud"

# Pipewire
link "pipewire/filter-chain.conf" ".config/pipewire/filter-chain.conf"

# Starship
link "starship.toml" ".config/starship.toml"

# Scripts
echo ""
echo "🔧 Installing scripts..."
for script in "$DOTFILES/scripts/"*; do
    [ -f "$script" ] && [ -x "$script" ] || continue
    name=$(basename "$script")
    cp "$script" "$HOME/.local/bin/$name"
    chmod +x "$HOME/.local/bin/$name"
    echo "  ✓ $name"
done

echo ""
echo "✨ Done! Restart Hyprland or reboot."
echo "📌 Backup: $BACKUP"
