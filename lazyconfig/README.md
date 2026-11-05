# LazyVim + C-Support - Guía de instalación

Dale esta carpeta a OpenCode y decile: **"Lee los archivos de configuración en esta carpeta y úsalos para instalar y configurar Neovim con LazyVim + C-Support exactamente igual que acá. Sigue las instrucciones en README.md."**

## Requisitos previos
- Ubuntu 22.04 (o similar)
- Git, curl, pip3, unzip ya instalados
- Acceso a `sudo` (se pedirá tu contraseña durante la instalación)

## Instalación paso a paso

### 1. Instalar Neovim v0.12.3 (desde GitHub release)
```bash
curl -LO https://github.com/neovim/neovim/releases/download/v0.12.3/nvim-linux64.tar.gz
sudo tar -C /usr/local -xzf nvim-linux64.tar.gz
rm nvim-linux64.tar.gz
# Verificar: nvim --version
```

### 2. Clonar LazyVim starter
```bash
git clone https://github.com/LazyVim/starter ~/.config/nvim
rm -rf ~/.config/nvim/.git
```

### 3. Copiar los archivos de configuración
Copiar **todo el contenido de `lua/`** de esta carpeta a `~/.config/nvim/lua/`.

### 4. Instalar system packages
```bash
sudo apt update && sudo apt install -y \
  cmake g++ gdb make lldb-14 clang-format-14 clang-tidy-14

# Node.js 20
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo bash -
sudo apt install -y nodejs
npm config set prefix ~/.npm-global
echo 'export PATH=~/.npm-global/bin:$PATH' >> ~/.bashrc
source ~/.bashrc

# cmakelang
pip3 install cmakelang cmakelint

# tree-sitter-cli v0.22.6 (compatible con GLIBC 2.35)
npm install -g tree-sitter-cli@0.22.6
```

### 5. Copiar el zip de C-Support y extraerlo
```bash
# Descargar a una ruta del USUARIO (no a /usr/src/ que requiere root)
curl -o ~/c-support.zip https://www.drchip.org/astronaut/vim/c-support/c-support.zip
unzip ~/c-support.zip -d ~/.local/share/nvim/lazy/c-support/
rm ~/c-support.zip
```

> ⚠️ **Raspberry Pi OS**: En Raspbian/RPi OS, `/usr/src/` **solo permite escritura con root**. Si el instalador del plugin te pide extraer ahí, **cancelá** y extraelo en `~/c-support.zip` como se muestra arriba. En Ubuntu/Debian desktop el problema puede no aparecer si tenés permisos de escritura en `/usr/src/`, pero la ruta de usuario es siempre segura.

### 6. Abrir Neovim por primera vez
```bash
nvim --headless "+Lazy! sync" +qa
nvim --headless "+TSInstallSync all" +qa
# Ignorar warnings de Mason
```

### 7. Iniciar Neovim normalmente
```bash
nvim
# Dentro de un archivo .c, correr :NTW para configurar nombre/email
```

## Archivos incluidos

| Archivo | Ruta destino | Descripción |
|---------|-------------|-------------|
| `init.lua` | `~/.config/nvim/init.lua` | Entry point |
| `lua/config/lazy.lua` | `~/.config/nvim/lua/config/lazy.lua` | Plugin spec order |
| `lua/config/options.lua` | `~/.config/nvim/lua/config/options.lua` | Leader keys, timeout, tabs, colores línea (rojo `#FF5500` relativo, verde `#39FF14` actual) |
| `lua/plugins/c-cpp.lua` | `~/.config/nvim/lua/plugins/c-cpp.lua` | clangd extra + codelldb + parsers |
| `lua/plugins/c-support.lua` | `~/.config/nvim/lua/plugins/c-support.lua` | C-Support plugin config (`C_MapLeader=\`, `C_OutputGvim=buffer`) |
| `lua/plugins/go-snippets.lua` | `~/.config/nvim/lua/plugins/go-snippets.lua` | Spec del plugin local de snippets Go (teclas `\`) |
| `lua/go-snippets/init.lua` | `~/.config/nvim/lua/go-snippets/init.lua` | Módulo de snippets Go (teclas `\` igual que c-support) |
| `lua/plugins/go.lua` | `lua/config/lazy.lua` (import) | Extra LazyVim de Go: LSP **gopls**, formateo y linting |
| `snippets/go.json` | `~/.config/nvim/snippets/go.json` | Snippets de Go (VSCode-style, los carga blink.cmp) |
| `lua/config/autocmds.lua` | `~/.config/nvim/lua/config/autocmds.lua` | Atajo `<F3>` para `go vet` (ver abajo) |

## Key bindings
- `<Space>` = LazyVim leader (find files, grep, etc)
- `\` = C-Support leader (snippets: `\swh`, `\im`, `\pih`, etc)
- Ver README.md original para tabla completa de snippets

## Snippets de Go

Los archivos `.go` cargan `~/.config/nvim/snippets/go.json`. Al escribir el **prefix** del snippet aparece en el menú de completado (blink.cmp):

| Prefix | Snippet |
|--------|---------|
| `gmain` | `func main() { ... }` |
| `gfunc` | `func name() { ... }` |
| `gerr` | `if err != nil { return err }` |
| `gfor` | `for i, v := range items { ... }` |
| `gfori` | `for i := 0; i < n; i++ { ... }` |
| `gif` | `if ${1:cond} { ... }` |
| `gifelse` | `if { } else { }` |
| `gelse` | `else { ... }` |
| `gwhile` | `for ${1:cond} { ... }` (while) |
| `gswitch` | `switch ${1:x} { case ... }` |
| `gcase` | `case ${1:val}:` |
| `gprintf` | `fmt.Printf("%v\n", ...)` |
| `gscanf` | `fmt.Scan(&val)` |
| `gstruct` | `type Name struct { ... }` |
| `ginterface` | `type Name interface { ... }` |
| `ggo` | `go func() { ... }()` |
| `gdefer` | `defer` |
| `ghandler` | `http.HandleFunc("/", ...)` |
| `gserver` | `http.ListenAndServe(":8080", nil)` |
| `gchan` | `ch := make(chan Type, 10)` |
| `gmutex` | `var mu sync.Mutex` |
| `gtest` | `func TestName(t *testing.T) { ... }` |
| `gbench` | `func BenchmarkName(b *testing.B) { ... }` |
| `gjson` | `json.Marshal(v)` |

Los tabstops (`$1`, `$2`, `$0`) permiten saltar entre campos con `Tab`. Esto es el **equivalente Neovim** de los snippets `\s...` de Vim (ver `vimconfig/GUIA_VIM.md`).

### Con la tecla `\` (igual que C++)

Además de los prefijos de completado, los **atajos de c-support funcionan igual** en Neovim dentro de archivos `.go` (módulo `go-snippets`): `\sif`, `\sie`, `\sei`, `\sel`, `\sw`, `\ss`, `\sc`, `\sb`, `\sfo`, `\sfr`, `\im`, `\if`, `\is`, `\ipr`, `\isc` y los extras de Go (`\se`, `\sg`, `\schan`, `\stt`, `\sbm`…). Funcionan en modo **normal e insert**. Visual: selección + `\sif`/`\sw`/`\ss`/`\sg` envuelve la selección. `timeoutlen` se ajusta a 400ms para que responda sin demora.

### Chequeo de sintaxis (LSP y lint)

El extra `lazyvim.plugins.extras.lang.go` (importado en `lua/config/lazy.lua`) activa:
- **gopls** (LSP): errores de sintaxis y de tipo en tiempo real (incluye `staticcheck`). Se instala solo por mason al abrir el primer `.go`.
- **conform**: formatea con `goimports` + `gofumpt` al guardar.
- **nvim-lint**: `golangci-lint` (lint al guardar).

Requiere el toolchain Go (`go`/`gofmt`); mascón instala `gopls`, `goimports`, `gofumpt` y `golangci-lint` automáticamente.

### Atajo F3: `go vet`

En cualquier archivo `.go`, `<F3>` (normal e insert) guarda el buffer y corre
`go vet .` sobre el paquete (la carpeta) del archivo que estás editando —no
todo el módulo, solo el paquete que tocaste. Si encuentra problemas abre la
quickfix list (`:copen`, saltar con `]q`/`[q` o Enter sobre un item); si no
encuentra nada, solo notifica "go vet: sin problemas".

Está definido en `lua/config/autocmds.lua`, es Lua puro (sin nada específico
de un SO), y solo depende de tener `go` en el `PATH`.

## Indentación

- `tabstop=4`, `shiftwidth=4`, `expandtab=false` en `options.lua`.
- clangd usa `--fallback-style={IndentWidth: 4}` (en `c-cpp.lua`). En **arm64 (RPi)** mason no tiene binarios de clangd: se usa el del sistema (`sudo apt install clangd clang-format`) y el server se declara con `mason = false` para que no intente descargarlo.
- `conform.nvim` usa `clang-format` con `--style={IndentWidth: 4}` para `.c` y `.cpp` al guardar.
- Si querés personalizar, creá un `.clang-format` en la raíz del proyecto.

## Notas importantes

- **`\rr` (Run)**: compila con `C_Link()` y ejecuta el programa. El output se muestra en un **split horizontal abajo** sin "Press ENTER" (gracias a `C_OutputGvim = "buffer"`). Cerrar con `:q`.
- **`\rt` (Run Terminal)**: compila y abre el programa en una **pestaña nueva con terminal interactiva** (soporta `scanf()`, `fgets()`, etc). Presioná `i` para empezar a escribir. Salir con `exit` + Enter o `:q`. Volver al código con `gt`.
- **`\rm` (Make)**: ejecuta `make` según el Makefile del proyecto.
- **`\rc` (Compile)**: compila el archivo actual sin linkear.
- Si querés pasar argumentos al programa, usá `\ra` antes de `\rr`/`\rt`.
