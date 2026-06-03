#!/bin/bash
# One-liner universal de despliegue de Claude Code para Juan
# Soporta: Ubuntu/Debian, CachyOS/Arch, MacOS
# Uso: PASS="vanejuanpabloana01" bash

set -e

# 1. Validación de Contraseña
if [ -n "$PASS" ]; then
    pass="$PASS"
else
    echo "🔐 Validación de acceso requerida..."
    read -s -p "Introduce la contraseña: " pass
    echo ""
fi

if [ "$pass" != "vanejuanpabloana01" ]; then
    echo "❌ Contraseña incorrecta. Acceso denegado."
    exit 1
fi

echo "✅ Acceso concedido. Detectando sistema operativo..."

# 2. Detección de OS y Gestor de Paquetes
OS="$(uname -s)"
if [ "$OS" = "Darwin" ]; then
    PKG_MGR="brew"
    echo "🍎 Sistema detectado: MacOS"
elif [ -f /etc/arch-release ]; then
    PKG_MGR="pacman"
    echo "🚀 Sistema detectado: CachyOS/Arch Linux"
elif [ -f /etc/debian_version ]; then
    PKG_MGR="apt"
    echo "🐧 Sistema detectado: Ubuntu/Debian"
else
    echo "❓ Sistema no soportado automáticamente. Intentando detección genérica..."
    PKG_MGR="unknown"
fi

# 3. Instalación de dependencias según el OS
install_deps() {
    case $PKG_MGR in
        "apt")
            echo "📦 Instalando dependencias vía apt..."
            sudo apt-get update
            sudo apt-get install -y unzip curl
            if ! command -v node &> /dev/null; then
                curl -fsSL https://deb.nodesource.com/setup_22.x | sudo -E bash -
                sudo apt-get install -y nodejs
            fi
            ;;
        "pacman")
            echo "📦 Instalando dependencias vía pacman..."
            sudo pacman -S --noconfirm unzip curl nodejs npm
            ;;
        "brew")
            echo "📦 Instalando dependencias vía brew..."
            if ! command -v brew &> /dev/null; then
                echo "Installing Homebrew first..."
                /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
                eval "$($(brew --prefix)/bin/brew shellenv)"
            fi
            brew install unzip curl node
            ;;
        *)
            echo "❌ No se pudo determinar el gestor de paquetes. Por favor, instala nodejs, npm y unzip manualmente."
            exit 1
            ;;
    esac
}

install_deps

# 4. Instalación de Claude Code
echo "🚀 Instalando @anthropic-ai/claude-code..."
sudo npm install -g @anthropic-ai/claude-code || npm install -g @anthropic-ai/claude-code

# 5. Restauración de configuración cifrada
echo "⚙️ Descargando y restaurando configuración cifrada..."
mkdir -p ~/.claude
curl -sSL https://github.com/ommerus/cc-juan/raw/master/config.zip -o /tmp/config.zip
unzip -P "$pass" -o /tmp/config.zip -d /tmp/claude_temp

# Manejo de rutas del ZIP (asegurar que el contenido vaya a ~/.claude)
if [ -d "/tmp/claude_temp/.claude" ]; then
    cp -r /tmp/claude_temp/.claude/* ~/.claude/
else
    cp -r /tmp/claude_temp/* ~/.claude/
fi

rm -rf /tmp/config.zip /tmp/claude_temp

echo "🎉 ¡Despliegue universal completado! Ya puedes ejecutar 'claude'."
