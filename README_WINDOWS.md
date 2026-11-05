# LazyVim + C-Support en Windows 11 (Warp)

Port de `lazyconfig/` (Ubuntu / Raspberry Pi OS) a Windows 11 + Warp + Neovim.
Todo se instaló **sin privilegios de administrador**, en rutas de usuario.

## Dónde quedó todo

| Qué | Ruta |
|-----|------|
| Config de Neovim (`= ~/.config/nvim`) | `%LOCALAPPDATA%\nvim` |
| Datos de Neovim (`= ~/.local/share/nvim`) | `%LOCALAPPDATA%\nvim-data` |
| Plugin c-support (zip extraído) | `%LOCALAPPDATA%\nvim-data\c-support` |
| Binarios portables | `%LOCALAPPDATA%\Programs\{Neovim,clangd,devbin}` |

## Qué se instaló

Descargado y extraído a mano (portable, nada de instaladores):

| Herramienta | Versión | Ruta |
|-------------|---------|------|
| Neovim | 0.12.5 | `%LOCALAPPDATA%\Programs\Neovim\bin` |
| clangd | 22.1.6 | `%LOCALAPPDATA%\Programs\clangd\bin` |
| ripgrep | 15.2.0 | `%LOCALAPPDATA%\Programs\devbin` |
| fd | 10.5.0 | `%LOCALAPPDATA%\Programs\devbin` |
| lazygit | 0.65.0 | `%LOCALAPPDATA%\Programs\devbin` |
| clang-format | 15.0.0 (del paquete npm) | `%LOCALAPPDATA%\Programs\devbin` |
| make | copia de `mingw32-make.exe` de WinLibs renombrada a `make.exe` | `%LOCALAPPDATA%\Programs\devbin` |

Esas tres carpetas se agregaron al **PATH de usuario**.

Vía otros gestores:

- `winget install Python.Python.3.13 --scope user` → lo necesita Mason para
  `cmakelang` / `cmakelint` (se instalan con pip).
- `npm install -g clang-format tree-sitter-cli`.

Ya estaban en el sistema y se reutilizaron: `git`, `node` 20, `go`, y de
**WinLibs mingw64** (`gcc`, `g++`, `gdb`, `cmake`, `ctags`, `mingw32-make`).

### Mason

Instalados: `codelldb`, `cmakelang`, `cmakelint`, `gofumpt`, `goimports`,
`golangci-lint`, `gopls`, `lua-language-server`, `neocmakelsp`, `json-lsp`,
`shfmt`, `stylua`.

`clangd` **no** se instala por Mason: se usa el del sistema (`mason = false` en
`c-cpp.lua`), igual que en la Raspberry.

### Treesitter

34 parsers compilados con el `gcc` de WinLibs (c, cpp, cmake, make, go, gomod,
gosum, gowork, gotmpl, lua, vim, markdown, bash, json, yaml, toml, …).

## Diferencias respecto a `lazyconfig/` (Linux)

La versión Windows de la config está guardada en **`lazyconfig-windows/`** de esta
misma carpeta (copia de lo que está vivo en `%LOCALAPPDATA%\nvim`). `lazyconfig/`
quedó intacta como referencia de Linux/RPi.

Son 3 cambios. `init.lua`, `lua/config/lazy.lua`, `lua/config/options.lua`,
`lua/go-snippets/init.lua`, `lua/plugins/go-snippets.lua` y `snippets/go.json`
quedaron **idénticos**.

### 1. `lua/plugins/c-support.lua` — reescrito

- Las rutas ya no están hardcodeadas a `~/.local/share/nvim/...`: ahora usan
  `vim.fn.stdpath("data")`, así que el archivo sirve igual en Linux y Windows.
- **c-support se movió FUERA de `lazy/`.** Esto es importante y también aplica a
  Linux: lazy.nvim trata cualquier directorio dentro de su root como un repo git,
  y al no encontrar `.git` en `lazy/c-support` revienta al arrancar con
  `lazy/manage/lock.lua:26: bad argument #1 to 'assert'`. Ahora va en
  `stdpath("data")/c-support`, es decir un nivel arriba de `lazy/`.
- Se definen `C_GlobalTemplateFile` **y** `C_LocalTemplateFile`: en Windows
  `plugin/c.vim` detecta "local installation" porque el directorio está bajo
  `$HOME`, y en ese caso lee el *local*, no el *global*.
- Se fijan `C_CCompiler = "gcc.exe"` y `C_CplusCompiler = "g++.exe"`.
- El mapeo `\rt` ahora arma el nombre del ejecutable con `.exe` y lo lanza con
  `shellescape`, más un chequeo de que exista antes de abrir la terminal.

### 2. `lua/plugins/c-cpp.lua` — solo un comentario

Cambió el comentario de `mason = false` (decía "arm64/aarch64"). El
comportamiento es el mismo.

### 3. `lua/plugins/win-fixes.lua` — nuevo

Archivo nuevo que en Linux no hace nada (`return {}`). Arregla un bug real de
`nvim-lint` en Windows:

`lint/linters/golangcilint.lua` decide si el archivo pertenece a un módulo
comparando `go env GOMOD` contra `/dev/null`, pero **en Windows Go devuelve
`NUL`**. Con esa detección fallando, si el cwd de nvim está fuera del módulo,
`golangci-lint` se ejecuta desde ahí y aborta con
`exit code 5: "no go files to analyze"` en **cada guardado** de un `.go`.

El fix envuelve el linter en una función (nvim-lint acepta que `linters[name]`
sea función y la llama en cada corrida) y fija `cwd` en la raíz del módulo del
buffer; si el archivo no tiene `go.mod`, le pasa el archivo en vez del
directorio, que es lo que hace la rama de Linux.

## Primer uso

1. **Reiniciá Warp** — el PATH nuevo se toma al abrir una terminal nueva.
2. Abrí un `.c` y corré `\ntw` una vez, para cargar nombre/mail en las
   plantillas de c-support (si no, avisa "personal details are not set" en cada
   arranque).

## Atajo `<F3>`: `go vet`

En cualquier archivo `.go`, `<F3>` (normal e insert) guarda el buffer y corre
`go vet .` sobre el paquete (carpeta) del archivo que estás editando. Si
encuentra problemas abre la quickfix list (`<C-q>`/`:copen`, saltar con
`]q`/`[q` o `Enter` sobre un item); si no encuentra nada, solo notifica
"sin problemas". Está en `lua/config/autocmds.lua` — es Vimscript/Lua puro sin
nada específico de Windows, así que el mismo bloque sirve tal cual en tu
`lazyconfig/` de Linux/RPi si lo querés llevar para allá.

## Verificado funcionando

- c-support: plantillas cargadas, `C_Installation = local`, todos los mapeos de
  `\` presentes en modo normal **e insert**.
- `\rc` (compile → `.obj`), `C_Link` (→ `.exe`), `\rr` (salida al buffer
  `C-Output`), `\rm` / `:Make` con Makefile.
- `\rt`: compila, abre pestaña con terminal y **`scanf()` lee la entrada**
  (ConPTY funciona bien).
- clangd adjunto en `.c`/`.cpp`; gopls adjunto en `.go`.
- Formateo al guardar: `clang-format` con `IndentWidth: 4` en C/C++,
  `goimports` + `gofumpt` en Go.
- `golangci-lint` reportando diagnósticos de verdad (probado con `errcheck`).
- Snippets de Go: los 25+ mapeos `\xx` del módulo `go-snippets` y
  `snippets/go.json` para blink.cmp. `timeoutlen` queda en 400ms.
- Colores de `options.lua`: `LineNr` `#FF5500`, `CursorLineNr` `#39FF14` bold.
- Portapapeles: `unnamedplus` contra el de Windows (LazyVim lo activa en
  `VeryLazy`, por eso en `--headless` se ve vacío; en sesión real está puesto).

## Limitaciones conocidas

- **Imágenes inline** (`snacks.image`) no funcionan: Warp no implementa el
  protocolo gráfico de Kitty. No afecta nada de C/C++/Go.
- Los *providers* de python/node/perl/ruby de Neovim quedaron sin instalar.
  Nada de esta config los usa (c-support es Vimscript puro), así que los
  warnings de `:checkhealth` son inofensivos.
- `luarocks` / `hererocks` sin instalar: lazy.nvim no podrá instalar plugins que
  lo requieran. Ninguno de los actuales lo hace.
- `clang-format` es la 15.0.0 (la que trae el paquete npm), más vieja que
  clangd. Para C/C++ con `IndentWidth: 4` alcanza de sobra.

## Reinstalar desde cero

```powershell
# borrar y volver a empezar
Remove-Item -Recurse -Force $env:LOCALAPPDATA\nvim, $env:LOCALAPPDATA\nvim-data

git clone https://github.com/LazyVim/starter $env:LOCALAPPDATA\nvim
Remove-Item -Recurse -Force $env:LOCALAPPDATA\nvim\.git

# copiar init.lua, lua\ y snippets\ desde lazyconfig-windows\ (NO desde lazyconfig\)
Copy-Item -Recurse -Force .\lazyconfig-windows\* $env:LOCALAPPDATA\nvim\

# extraer c-support.zip en $env:LOCALAPPDATA\nvim-data\c-support   <-- NO dentro de lazy\
Expand-Archive .\c-support.zip -DestinationPath $env:LOCALAPPDATA\nvim-data\c-support

nvim --headless "+Lazy! sync" +qa
nvim            # mason y treesitter terminan solos al abrir el primer archivo
```

## Opcional: arranque más rápido

Neovim arranca en ~590ms, y **500ms de eso es sourcear `c-support/plugin/c.vim`**
(122 KB de Vimscript, cargado siempre porque el spec dice `lazy = false`). Es lo
mismo que pasa en Linux, no es un problema de Windows.

Si te molesta, en `lua/plugins/c-support.lua` podés cambiar:

```lua
lazy = false,
```

por:

```lua
ft = { "c", "cpp" },
```

y c-support se carga recién al abrir el primer `.c`/`.cpp`. Contra: los comandos
globales que define (`:Make`, `:NTW`, …) no existen hasta que abras un archivo de
C. Probalo antes de dejarlo así.
