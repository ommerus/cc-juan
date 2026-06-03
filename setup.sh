#!/bin/bash
# One-liner de despliegue de Claude Code para Juan
# Soporta PASS="contraseña" bash

set -e

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

echo "✅ Acceso concedido. Iniciando despliegue de Claude Code..."

# Instalación de dependencias básicas (unzip es necesario para el ZIP)
if ! command -v unzip &> /dev/null; then
    echo "📦 Instalando unzip..."
    sudo apt-get update && sudo apt-get install -y unzip
fi

if ! command -v node &> /dev/null; then
    echo "📦 Instalando Node.js..."
    curl -fsSL https://deb.nodesource.com/setup_22.x | sudo -E bash -
    sudo apt-get install -y nodejs
fi

echo "🚀 Instalando @anthropic-ai/claude-code..."
sudo npm install -g @anthropic-ai/claude-code

echo "⚙️ Descargando y restaurando configuración cifrada..."
mkdir -p ~/.claude
curl -sSL https://github.com/ommerus/cc-juan/raw/master/config.zip -o /tmp/config.zip
unzip -P "$pass" -o /tmp/config.zip -d /tmp/claude_temp
# El zip contiene la carpeta .claude, movemos el contenido
cp -r /tmp/claude_temp/.claude/* ~/.claude/ 2>/dev/null || cp -r /tmp/claude_temp/* ~/.claude/
rm -rf /tmp/config.zip /tmp/claude_temp

echo "🎉 ¡Despliegue completado! Ya puedes ejecutar 'claude'."
