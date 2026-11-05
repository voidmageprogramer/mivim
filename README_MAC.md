# LazyVim + C-Support en macOS

Port de `lazyconfig/` (Ubuntu / Raspberry Pi OS) a macOS (Apple Silicon / Intel).

## Requisitos

- macOS 13+ (Ventura o posterior)
- **Terminal truecolor obligatoria**: la Terminal.app de macOS **no soporta
  truecolor** (colores de 24 bits). Sin truecolor, Neovim ignora los colores
  del colorscheme y muestra todo en blanco. Se recomienda **Ghostty** (la más
  ligera), o como alternativa iTerm2, kitty, WezTerm o Alacritty.

## Dónde queda todo

| Qué | Ruta |
|-----|------|
| Config de Neovim (`= ~/.config/nvim`) | `~/.config/nvim` |
| Datos de Neovim (`= ~/.local/share/nvim`) | `~/.local/share/nvim` |
| Plugin c-support (zip extraído) | `~/.local/share/nvim/c-support` |
| clangd del sistema | `/usr/bin/clangd` (Xcode CommandLineTools) |
| Config de Ghostty | `~/.config/ghostty/config` |

## Qué se instaló (vía Homebrew)

- **Neovim 0.12+**, `node`, `ripgrep`, `fd`, `lazygit`, `clang-format`, `cmake`, `go`.
- **Ghostty** (terminal truecolor) + **JetBrainsMono Nerd Font** (iconos).
- Se usa del sistema (CLT): `clangd`, `gcc`/`g++` (wrappers de clang), `make`.
- El zip `c-support.zip` se extrae en `~/.local/share/nvim/c-support`
  (**fuera de `lazy/`**): lazy.nvim trata todo lo que esté dentro de su root
  como repo git y sin `.git` revienta al arrancar con
  `lazy/manage/lock.lua:26`. Lo mismo que se corrigió para Windows.

---

## Instalación

```bash
bash install_mac.sh
```

El script instala todo en orden:
1. Homebrew (si falta)
2. Paquetes: neovim, node, ripgrep, fd, lazygit, clang-format, cmake, go
3. **Ghostty** (terminal truecolor)
4. **JetBrainsMono Nerd Font** (para iconos de LazyVim)
5. Config de Neovim (`lazyconfig-mac/` → `~/.config/nvim`)
6. Plugin c-support (extraído de `c-support.zip`)
7. Instalación headless de lazy.nvim + Mason + tree-sitter parsers

Si ya tenías `~/.config/nvim`, se respalda con sufijo de fecha.

### Verificar truecolor

Después de instalar Ghostty, pegá esto en la terminal:

```bash
printf '\033[38;2;255;0;0mROJO  \033[38;2;0;255;0mVERDE  \033[38;2;0;0;255mAZUL\033[0m\n'
```

Si ves ROJO/VERDE/AZUL en color → truecolor funciona.
Si sale blanco/gris → la terminal no soporta truecolor (usá Ghostty).

---

## Primer uso

1. **Abrí Ghostty** (no Terminal.app) — la primera vez abrila desde
   `/Applications/Ghostty.app`.
2. Dentro de Ghostty, abrí `nvim`: lazy.nvim instala los plugins, Mason
   las tools y tree-sitter los parsers (la primera apertura tarda unos minutos).
3. Dentro de un `.c`, corré `\ntw` una vez para cargar nombre/email en las
   plantillas de c-support (si no, avisa "personal details are not set").

---

## Tema, fondo negro y colores de sintaxis

La config de Neovim incluye `lua/plugins/ui.lua` que hace 3 cosas:

### Fondo negro puro

El colorscheme **tokyonight-moon** (dark) se fuerza con fondo `#000000` en
todas las áreas: buffer, float, statusline, pestañas, columnas.

### Sintaxis colorida (estilo VSCode)

En Go y C/C++ la mayoría de tokens son **variables/identificadores**; sin
override, se dibujan del mismo blanco que el texto normal y se lee como "un
solo color". El spec fuerza colores distintos por grupo:

| Grupo | Color | Hex |
|-------|-------|-----|
| Variables (`@variable`) | azul claro | `#9CDCFE` |
| Funciones / métodos (`@function`) | amarillo | `#DCDCAA` |
| Tipos (`@type`) | teal | `#78dce8` |
| Strings (`@string`) | verde | `#c3e88d` |
| Números / constantes (`@number`, `@constant`) | ámbar | `#ffc777` |
| Keywords (`@keyword`) | magenta | `#fca7ea` |
| Parámetros (`@parameter`) | durazno | `#ffc777` |
| Campos (`@field`, `@property`) | cyan | `#89ddff` |
| Operadores (`@operator`) | cyan | `#89ddff` |
| Comentarios (`@comment`) | violeta atenuado, italic | `#636da6` |

### Colores de línea

- `LineNr`: rojo `#FF5500` sobre fondo negro
- `CursorLineNr`: verde `#39FF14` bold sobre fondo negro

Para confirmar que los colores se aplican, abrí un archivo `.go` en nvim y
verificá que `func`, `:=`, strings y variables se vean en colores distintos.

---

## Comprobaciones rápidas

- c-support: `:C_Installation` → `local`; mapeos de `\` en modo normal **e insert**.
- `\rc` (compile → `.o`), `C_Link` (→ ejecutable), `\rr` (salida al buffer
  `C-Output`), `\rm` / `:Make`.
- `\rt`: compila, abre pestaña con terminal interactiva (`scanf()` lee entrada).
- clangd adjunto en `.c`/`.cpp`; gopls en `.go`.
- Formateo al guardar: `clang-format` (IndentWidth 4) en C/C++; `goimports` +
  `gofumpt` en Go.
- `<F3>` en `.go`: `go vet` sobre el paquete, con quickfix si hay problemas.
- Snippets Go: `\sif`, `\gmain`, etc. (módulo `go-snippets`) y
  `snippets/go.json` para blink.cmp.

---

## Ghostty (terminal)

Ghostty es una terminal de código abierto para macOS que soporta truecolor,
es ligera y viene con temas built-in. La config se encuentra en:

```
~/.config/ghostty/config
```

Configuración actual:

```
theme = TokyoNight Moon        # tema oscuro (built-in)
font-family = JetBrainsMonoNerdFont
font-size = 13
background = 1e1e28            # fondo oscuro (override del tema)
foreground = c8d3f5
cursor-style = block
window-padding-x = 8
window-padding-y = 8
```

Para cambiar el tamaño de fuente: editá `~/.config/ghostty/config` y cambiá
`font-size`. Ghostty carga los cambios al reiniciarse (Cmd+Q y reabrir).

### ¿Por qué no Terminal.app?

La Terminal.app de macOS **no soporta truecolor** (solo 256 colores).
Cuando Neovim manda colores RGB via secuencias de escape (que es lo que hace
tokyonight y cualquier colorscheme moderno), la Terminal.app los ignora y
muestra todo en blanco. Las palabras que aparecen "resaltadas" son las que
tokyonight marca en negrita/cursiva — pero sin truecolor, los colores
propiamente dichos se pierden.

Para verificar si tu terminal soporta truecolor:

```bash
printf '\033[38;2;255;0;0mROJO  \033[38;2;0;255;0mVERDE  \033[38;2;0;0;255mAZUL\033[0m\n'
```

Si ves los tres colores reales → truecolor funciona.
Si sale todo blanco/gris → tu terminal no soporta truecolor (usá Ghostty).

---

## Si Mason no puede bajar codelldb

```bash
rm -rf ~/.local/share/nvim/mason/packages/codelldb ~/.local/share/nvim/mason/opt/lldb
rm -f  ~/.local/share/nvim/mason/bin/codelldb
# luego dentro de nvim: :MasonInstall codelldb
```

## Reinstalar desde cero

```bash
rm -rf ~/.config/nvim ~/.local/share/nvim ~/.config/ghostty
bash install_mac.sh
```
