#!/bin/bash
# =============================================================
#  Instalador para macOS (Apple Silicon / Intel)
#  Configuración: Neovim (LazyVim) + C-Support + snippets Go
#
#  Uso:
#    Copiar esta carpeta entera y ejecutar:
#      bash install_mac.sh
#
#  Instala (vía Homebrew):
#    - Neovim            (editor)
#    - node              (usado por Mason/algunas tools de LazyVim)
#    - ripgrep, fd       (búsqueda de LazyVim)
#    - lazygit           (git integrado de LazyVim)
#    - clang-format      (formateo C/C++ al guardar)
#    - cmake             (compilación / treesitter)
#    - go                (toolchain Go: gopls, goimports, gofumpt, vet)
#    - Ghostty           (terminal con truecolor: obligatoria, la Terminal.app
#                         de macOS no muestra los colores de Neovim)
#    - JetBrainsMono Nerd Font (iconos de LazyVim)
#
#  TRUECOLOR: sin una terminal que soporte truecolor los char de Neovim no se ven
#  en color (todo blanco). Ghostty ya viene configurada en ~/.config/ghostty.
#
#  Usa del sistema (Xcode CommandLineTools): clangd, gcc/g++, make.
#  La config declara clangd con `mason = false` y usa el del PATH.
# =============================================================

set -e
cd "$(dirname "$0")"

# ---------- Colores ----------
GRN=$'\033[0;32m'; YLW=$'\033[1;33m'; RED=$'\033[0;31m'; BLU=$'\033[0;34m'; NC=$'\033[0m'
ok()   { echo -e "${GRN}[ OK ]${NC} $1"; }
info() { echo -e "${BLU}[>>>]${NC} $1"; }
warn() { echo -e "${YLW}[ !! ]${NC} $1"; }
err()  { echo -e "${RED}[FAIL]${NC} $1"; }

# ---------- Detectar macOS ----------
if [ "$(uname -s)" != "Darwin" ]; then
  err "Este instalador es para macOS. En Linux/RPi usá install_rpi.sh y en Windows la carpeta lazyconfig-windows."
  exit 1
fi
ARCH=$(uname -m)
info "macOS detectado | arquitectura: $ARCH"

# ---------- 1. Homebrew ----------
if ! command -v brew >/dev/null 2>&1; then
  info "Instalando Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  if [ "$ARCH" = "arm64" ]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  else
    eval "$(/usr/local/bin/brew shellenv)"
  fi
else
  ok "Homebrew: $(command -v brew)"
fi

# ---------- 2. Paquetes ----------
info "Instalando paquetes vía Homebrew (neovim, node, ripgrep, fd, lazygit, clang-format, cmake, go, ghostty, nerd font)..."
brew install neovim node ripgrep fd lazygit clang-format cmake go
brew install --cask ghostty font-jetbrains-mono-nerd-font
ok "Paquetes instalados"

info "Verificando herramienta de C de Xcode..."
if command -v clangd >/dev/null 2>&1; then
  ok "clangd: $(clangd --version | head -1)"
else
  warn "clangd NO está (¿falta Xcode CommandLineTools?). Ejecutar: xcode-select --install"
fi

# ---------- 2b. Config de Ghostty (terminal truecolor) ----------
GHOSTTY_CFG="$HOME/.config/ghostty/config"
if [ ! -f "$GHOSTTY_CFG" ]; then
  mkdir -p "$(dirname "$GHOSTTY_CFG")"
  cat > "$GHOSTTY_CFG" <<'EOF'
theme = TokyoNight Moon
font-family = JetBrainsMonoNerdFont
font-size = 13
background = 1e1e28
foreground = c8d3f5
cursor-style = block
window-padding-x = 8
window-padding-y = 8
EOF
  ok "Config de Ghostty creada en ~/.config/ghostty/config"
else
  ok "Ghostty ya tiene config (~/.config/ghostty/config), no se toca"
fi

# ---------- 3. Configuración de Neovim ----------
NVIM_CFG_DIR="$HOME/.config/nvim"
if [ -d "$NVIM_CFG_DIR" ]; then
  mv "$NVIM_CFG_DIR" "$NVIM_CFG_DIR.backup.$(date +%Y%m%d_%H%M%S)" 2>/dev/null || true
  warn "Carpeta ~/.config/nvim previa respaldada"
fi
mkdir -p "$NVIM_CFG_DIR"
cp -r lazyconfig-mac/init.lua "$NVIM_CFG_DIR/"
cp -r lazyconfig-mac/lua "$NVIM_CFG_DIR/"
cp -r lazyconfig-mac/snippets "$NVIM_CFG_DIR/"
ok "Config copiada a ~/.config/nvim (versión macOS)"

# ---------- 4. Plugin c-support ----------
# El zip se extrae FUERA de lazy/ (en ~/.local/share/nvim/c-support): lazy.nvim
# trata todo lo que esté dentro de su root como repo git y revienta al arrancar.
CSUPPORT_DIR="$HOME/.local/share/nvim/c-support"
if [ ! -e "$CSUPPORT_DIR/plugin/c.vim" ]; then
  if [ -f c-support.zip ]; then
    info "Extrayendo c-support.zip en $CSUPPORT_DIR ..."
    mkdir -p "$CSUPPORT_DIR"
    unzip -q -o c-support.zip -d "$CSUPPORT_DIR"
  else
    info "No hay c-support.zip; clonando desde GitHub..."
    git clone --depth 1 https://github.com/WolfgangMehner/c-support.git "$CSUPPORT_DIR"
  fi
fi
if [ -e "$CSUPPORT_DIR/c-support/templates/Templates" ]; then
  ok "c-support instalado (plantillas y snippets OK)"
else
  warn "c-support extraído pero no se encuentra c-support/templates/Templates; revisá la estructura del zip"
fi

# ---------- 5. Instalación de plugins (primera apertura) ----------
if command -v nvim >/dev/null 2>&1; then
  info "Disparando instalación de lazy.nvim (headless)..."
  nvim --headless "+Lazy! sync" +qa 2>/dev/null || true
  ok "plugins instalados/sincronizados"
fi

# ---------- 6. Verificación ----------
info "Verificando herramientas:"
for tool in nvim git go node rg fd lazygit clangd clang-format cmake make gcc; do
  if command -v "$tool" >/dev/null 2>&1; then
    ok "${tool}: $(command -v "$tool")"
  else
    warn "${tool}: NO ENCONTRADO"
  fi
done
if [ -d "/Applications/Ghostty.app" ]; then
  ok "Ghostty: /Applications/Ghostty.app"
else
  warn "Ghostty: NO instalado"
fi

echo ""
echo "=============================================================="
echo "  INSTALACIÓN COMPLETADA"
echo "=============================================================="
echo ""
echo -e "${GRN}  Neovim: ${NC}$(nvim --version | head -1 | awk '{print $1, $2}')"
echo ""
echo -e "${YLW}  PRÓXIMOS PASOS:${NC}"
echo "   1. Abre Ghostty (NO Terminal.app, no soporta truecolor):  /Applications/Ghostty.app"
echo "   2. Dentro de Ghostty abre nvim:  nvim   (primer arranque instala plugins + Mason + árboles treesitter)"
echo "   3. Dentro de un .c:   :NTW   para cargar nombre/email en las plantillas de c-support"
echo "   4. Snippets C/C++:    \\swh, \\im, \\pih ...   (leader \\ )"
echo "   5. Snippets Go:       \\sif, \\gmain ...       (leader \\ )"
echo "   6. Verificar truecolor:"
echo "      printf '\\033[38;2;255;0;0mROJO  \\033[38;2;0;255;0mVERDE  \\033[38;2;0;0;255mAZUL\\033[0m\\n'"
echo ""
echo "  Archivos:"
echo "   Config    -> ~/.config/nvim"
echo "   Ghostty   -> ~/.config/ghostty/config"
echo "   c-support -> ~/.local/share/nvim/c-support"
echo "=============================================================="