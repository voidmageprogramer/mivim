#!/bin/bash
# =============================================================
#  Instalador para Raspberry Pi 400
#  Configuración: Vim (vimconfig) + Neovim (LazyVim/lazyconfig)
#
#  Uso:
#    Copiar esta carpeta entera a la Raspberry Pi y ejecutar:
#      bash install_rpi.sh
#
#  Se instalará (root vía sudo):
#    - Vim 9+ desde apt
#    - Neovim (última estable, binario ARM64) en /opt/nvim
#    - Dependencias: git, curl, nodejs, fzf, ripgrep, clangd, cmake...
#    - En arm64 se usa el clangd del sistema (el paquete de mason no tiene binarios ARM)
#    - .vimrc + vim-plug + plugins
#    - ~/.config/nvim (LazyVim) + lazy.nvim + plugins
# =============================================================

set -e
cd "$(dirname "$0")"

# ---------- Colores ----------
GRN=$'\033[0;32m'; YLW=$'\033[1;33m'; RED=$'\033[0;31m'; BLU=$'\033[0;34m'; NC=$'\033[0m'
ok()   { echo -e "${GRN}[ OK ]${NC} $1"; }
info() { echo -e "${BLU}[>>>]${NC} $1"; }
warn() { echo -e "${YLW}[ !! ]${NC} $1"; }
err()  { echo -e "${RED}[FAIL]${NC} $1"; }

# ---------- Detectar arquitectura ----------
ARCH=$(uname -m)
case "$ARCH" in
  aarch64|arm64) RPI_ARCH="arm64" ;;
  armv7l|armv6l) RPI_ARCH="$ARCH" ;;
  *) warn "Arquitectura desconocida: $ARCH (si no es ARM esto no aplica)" ;;
esac
info "Arquitectura detectada: $ARCH"

# ---------- 1. Actualizar sistema ----------
info "Actualizando el sistema..."
sudo apt update && sudo apt full-upgrade -y
ok "Sistema actualizado"

# ---------- 2. Dependencias base ----------
info "Instalando dependencias base..."
sudo apt install -y \
  git curl wget unzip tar ca-certificates \
  build-essential pkg-config \
  vim vim-gtk3 \
  nodejs npm \
  fzf ripgrep \
  fonts-powerline \
  clang clangd clang-format lldb \
  cmake ninja-build \
  python3 python3-pip python3-venv \
  fd-find
ok "Dependencias base instaladas"

# ---------- Nota ARM64: clangd del sistema ----------
# En Raspberry Pi (arm64) el paquete clangd de mason no publica binarios,
# así que LazyVim/Neovim usa el clangd que acabamos de instalar por apt.
# La config ya lo contempla: lua/plugins/c-cpp.lua declara clangd con `mason = false`.
if [ "$RPI_ARCH" = "arm64" ]; then
  info "ARM64: se usa el clangd del sistema para el LSP (mason no tiene binarios ARM)"
  if command -v clangd >/dev/null 2>&1; then
    ok "clangd: $(clangd --version | head -1)"
  else
    warn "clangd NO instalado; ejecutar: sudo apt install clangd clang-format"
  fi
fi

# En Debian bookworm fd-find se llama "fdfind"
if [ -f /usr/bin/fdfind ] && [ ! -e "$HOME/.local/bin/fd" ]; then
  mkdir -p "$HOME/.local/bin"
  ln -sf /usr/bin/fdfind "$HOME/.local/bin/fd"
  ok "Enlazado fdfind -> fd"
fi

# ---------- 3. Fuente Nerd Font (opcional pero recomendada) ----------
info "Instalando fuente Nerd Font (JetBrainsMono) para iconos..."
FONT_URL="https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip"
if curl -fsSL -o /tmp/jetbrains-mono.zip "$FONT_URL"; then
  mkdir -p /tmp/jetbrains-mono && unzip -q -o /tmp/jetbrains-mono.zip -d /tmp/jetbrains-mono
  sudo mkdir -p /usr/local/share/fonts
  sudo cp /tmp/jetbrains-mono/*.ttf /usr/local/share/fonts/ 2>/dev/null || true
  sudo fc-cache -f >/dev/null 2>&1 || true
  rm -rf /tmp/jetbrains-mono* /tmp/jetbrains-mono.zip
  ok "Nerd Font instalada"
else
  warn "No se pudo bajar la Nerd Font (continuando sin ella)"
fi

# ---------- 4. Neovim (última estable) ----------
info "Instalando Neovim (última estable)..."
NVIM_DIR="/opt/nvim"
NVIM_VER=""
download_json=$(curl -fsSL "https://api.github.com/repos/neovim/neovim/releases/latest" 2>/dev/null || echo "")
NVIM_TAG=$(echo "$download_json" | grep '"tag_name"' | head -1 | sed 's/.*"tag_name": "\(.*\)".*/\1/')
ok "Versión Neovim detectada: ${NVIM_TAG:-latest}"

if [ "$RPI_ARCH" = "arm64" ]; then
  NVIM_TARBALL="nvim-linux-arm64.tar.gz"
else
  # Fallback: compilar desde fuente (lento pero funcional). Ruta no usada si ya existen binarios.
  NVIM_TARBALL=""
fi

if [ -n "$NVIM_TARBALL" ]; then
  if curl -fsSL -o /tmp/nvim.tar.gz \
        "https://github.com/neovim/neovim/releases/latest/download/$NVIM_TARBALL"; then
    sudo mkdir -p "$NVIM_DIR"
    sudo tar -xzf /tmp/nvim.tar.gz -C "$NVIM_DIR" --strip-components=1
    sudo ln -sf "$NVIM_DIR/bin/nvim" /usr/local/bin/nvim
    rm -f /tmp/nvim.tar.gz
    ok "Neovim instalado en $NVIM_DIR"
  else
    warn "No se pudo descargar binario ARM64 de Neovim; probando apt..."
    sudo apt install -y neovim
  fi
else
  info "Compilando Neovim desde fuente (puede tardar 30-60 min en RPi 400)..."
  sudo apt install -y gettext libtool libtool-bin autoconf automake cmake g++ pkg-config unzip
  git clone --depth 1 https://github.com/neovim/neovim /tmp/neovim
  cd /tmp/neovim
  make CMAKE_BUILD_TYPE=RelWithDebInfo -j"$(nproc)"
  sudo make install
  cd -
  rm -rf /tmp/neovim
  ok "Neovim compilado e instalado"
fi

info "Verificando Neovim..."
nvim --version | head -3

# ---------- 5. Configuración de Vim ----------
info "Configurando Vim (vimconfig)..."
VIMRC_SOURCE="$(pwd)/vimconfig/.vimrc"
if [ -f "$VIMRC_SOURCE" ]; then
  # Backup del .vimrc existente
  if [ -f "$HOME/.vimrc" ] || [ -L "$HOME/.vimrc" ]; then
    cp -L "$HOME/.vimrc" "$HOME/.vimrc.backup.$(date +%Y%m%d_%H%M%S)" 2>/dev/null || true
    warn ".vimrc previo respaldado"
  fi
  cp "$VIMRC_SOURCE" "$HOME/.vimrc"
  mkdir -p "$HOME/.vim"/{undo,backup,swap,plugged}
  ok ".vimrc instalado en $HOME/.vimrc"
else
  warn "No se encontró vimconfig/.vimrc; se omite la config de Vim"
fi

# Snippets de Go para Vim (plugin + ftplugin)
for gf in plugin/go_support.vim ftplugin/go.vim; do
  if [ -f "$(pwd)/vimconfig/$gf" ]; then
    mkdir -p "$HOME/.vim/$(dirname "$gf")"
    cp "$(pwd)/vimconfig/$gf" "$HOME/.vim/$gf"
    ok "Instalado vimconfig/$gf en ~/.vim/$gf"
  else
    warn "No se encontró vimconfig/$gf; se omite"
  fi
done

# Instalar vim-plug
if [ ! -f "$HOME/.vim/autoload/plug.vim" ]; then
  info "Instalando vim-plug..."
  curl -fLo "$HOME/.vim/autoload/plug.vim" --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
fi
ok "vim-plug listo"

# ---------- 6. Configuración de Neovim (LazyVim) ----------
info "Configurando Neovim (LazyVim)..."
NVIM_CFG_DIR="$HOME/.config/nvim"
if [ -d "$NVIM_CFG_DIR" ]; then
  mv "$NVIM_CFG_DIR" "$NVIM_CFG_DIR.backup.$(date +%Y%m%d_%H%M%S)" 2>/dev/null || true
  warn "Carpeta ~/.config/nvim previa respaldada"
fi
mkdir -p "$NVIM_CFG_DIR"
cp -r lazyconfig/init.lua "$NVIM_CFG_DIR/"
cp -r lazyconfig/lua "$NVIM_CFG_DIR/"
ok "Config de Neovim copiada a ~/.config/nvim"

# Snippets VSCode-style para Neovim (blink.cmp los carga desde ~/.config/nvim/snippets)
if [ -d "$(pwd)/lazyconfig/snippets" ]; then
  mkdir -p "$NVIM_CFG_DIR/snippets"
  cp -r "$(pwd)/lazyconfig/snippets/." "$NVIM_CFG_DIR/snippets/"
  ok "Snippets de Neovim copiados a ~/.config/nvim/snippets"
else
  warn "No se encontró lazyconfig/snippets; se omite"
fi

# Plugin c-support (plugin local del config de C/C++)
CSUPPORT_DIR="$HOME/.local/share/nvim/lazy/c-support"
if [ ! -d "$CSUPPORT_DIR" ]; then
  info "Instalando plugin c-support para C/C++..."
  mkdir -p "$(dirname "$CSUPPORT_DIR")"
  git clone --depth 1 https://github.com/WolfgangMehner/c-support.git "$CSUPPORT_DIR" 2>/dev/null || warn "No se pudo clonar c-support"
  # Instalar dentro de ~/.vim también para que funcione fuera de Neovim (opcional)
  cp -r "$CSUPPORT_DIR/c-support" "$HOME/.vim/c-support" 2>/dev/null || true
fi
ok "c-support listo"

# ---------- 7. Instalación de plugins (primera apertura) ----------
info "Instalando plugins de Vim (vim +PlugInstall)..."
if command -v vim >/dev/null 2>&1; then
  vim -u ~/.vimrc +PlugInstall --sync +qall 2>&1 | tail -5
  ok "Plugins de Vim instalados"
fi

info "Instalando plugins de Neovim (lazy.nvim se encarga en la primera apertura)..."
warn "Al abrir 'nvim' por primera vez, lazy.nvim descargará e instalará todos los plugins automáticamente."
warn "Esto tarda unos minutos en una Raspberry Pi 400. No interrumpas el proceso."

# Init de nvim para disparar install (headless)
if command -v nvim >/dev/null 2>&1; then
  info "Disparando instalación de lazy.nvim (headless)..."
  timeout 300 nvim --headless "+Lazy! install" +qa 2>/dev/null || true
  ok "lazy.nvim instalado y plugins iniciales procesados"
fi

# ---------- 8. COC ----------
info "Configurando dependencias de COC (autocompletado Vim)..."
if command -v npm >/dev/null 2>&1; then
  mkdir -p "$HOME/.config/coc/extensions"
  echo "{\"dependencies\":{}}"> "$HOME/.config/coc/extensions/package.json" 2>/dev/null || true
  ok "Directorio de extensiones de COC creado"
fi
warn "Para añadir soporte de lenguajes en COC ejecuta dentro de Vim:"
warn "  :CocInstall coc-json coc-python coc-tsserver coc-yaml coc-html coc-css"
warn "  :CocInstall coc-clangd"

# ---------- 9. Dependencias de LazyVim ----------
info "Verificando herramientas para LazyVim (C/C++):"
for tool in clangd clang-format cmake ninja gcc g++ python3 node ripgrep fd rg; do
  if command -v "$tool" >/dev/null 2>&1; then
    ok "${tool}: $(command -v "$tool")"
  else
    warn "${tool}: NO ENCONTRADO"
  fi
done

# Nota sobre codelldb (debugger C/C++ de LazyVim)
# En la primera instalación lo baja mason; si quedó a medio instalar por un
# arranque abortado, puede fallar con "already linked". Limpieza rápida:
warn "Si mason da 'codelldb ... already linked' tras un arranque abortado:"
warn "  rm -rf ~/.local/share/nvim/mason/packages/codelldb ~/.local/share/nvim/mason/opt/lldb"
warn "  rm -f  ~/.local/share/nvim/mason/bin/codelldb   # luego: :MasonInstall codelldb"

# ---------- 10. Limpieza y resumen ----------
echo ""
echo "=============================================================="
echo "  INSTALACIÓN COMPLETADA"
echo "=============================================================="
echo ""
echo -e "${GRN}  Vim: ${NC}$(vim --version | head -1)"
echo -e "${GRN}  Neovim: ${NC}$(nvim --version | head -1 | awk '{print $1, $2}')"
echo ""
echo -e "${YLW}  PRÓXIMOS PASOS:${NC}"
echo "   1. Abre nvim:        nvim   (primer arranque instala plugins)"
echo "   2. Abre vim:         vim"
echo "   3. Plugins coc:      :CocInstall coc-clangd  (dentro de vim)"
echo "   4. Terminal con Nerd Font para los iconos."
echo "   5. Cambia la contraseña root:  passwd"
echo ""
echo "  Archivos de configuración:"
echo "   Vim   -> ~/.vimrc  (edita ~/.vimrc.local para personalizar)"
echo "   Neovim-> ~/.config/nvim"
echo "=============================================================="