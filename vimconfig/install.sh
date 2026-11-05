#!/bin/bash
# Instalador automático de configuración Vim
# Uso: bash install.sh

set -e

VIMRC_SOURCE="$HOME/vimconfig/.vimrc"
VIMRC_DEST="$HOME/.vimrc"
VIM_DIR="$HOME/.vim"
PLUG_VIM="$VIM_DIR/autoload/plug.vim"

echo "🔧 Instalando configuración de Vim..."
echo ""

# 1. Backup existente
if [ -f "$VIMRC_DEST" ] || [ -L "$VIMRC_DEST" ]; then
    BACKUP="$VIMRC_DEST.backup.$(date +%Y%m%d_%H%M%S)"
    echo "📦 Backup de .vimrc actual: $BACKUP"
    mv "$VIMRC_DEST" "$BACKUP"
fi

# 2. Crear symlink al .vimrc
echo "🔗 Enlazando .vimrc..."
ln -sf "$VIMRC_SOURCE" "$VIMRC_DEST"

# 3. Crear directorios de vim
echo "📁 Creando directorios de Vim..."
mkdir -p "$VIM_DIR"/{undo,backup,swap,plugged}

# 4. Instalar vim-plug
if [ ! -f "$PLUG_VIM" ]; then
    echo "📦 Instalando vim-plug..."
    curl -fLo "$PLUG_VIM" --create-dirs \
        https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
else
    echo "✅ vim-plug ya instalado"
fi

# 5. Instalar plugins (en background para no bloquear)
echo "🔌 Instalando plugins..."
vim +PlugInstall +qall 2>/dev/null || true

echo ""
echo "✅ ¡Instalación completada!"
echo ""
echo "📋 Próximos pasos:"
echo "  1. Abre Vim: vim"
echo "  2. Instala plugins de COC (opcional): :CocInstall coc-json coc-python coc-tsserver"
echo "  3. Instala una Nerd Font para iconos: https://www.nerdfonts.com/"
echo "  4. Lee la guía: cat ~/vimconfig/GUIA_VIM.md"
echo ""
echo "🔧 Para personalizar: crea ~/.vimrc.local con tus ajustes"