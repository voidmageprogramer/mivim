# Guía de Configuración de Vim

## 📁 Estructura de Archivos

```
~/.vimconfig/
├── .vimrc          # Archivo principal de configuración
├── .vim/           # Directorio de datos de Vim (se crea automáticamente)
│   ├── plugged/    # Plugins instalados con vim-plug
│   ├── undo/       # Historial de deshacer persistente
│   ├── backup/     # Archivos de respaldo
│   └── swap/       # Archivos de intercambio
```

## 🚀 Instalación Rápida

### 1. Clona o copia esta configuración
```bash
# Opción A: Usar directamente esta carpeta
ln -s ~/vimconfig/.vimrc ~/.vimrc

# Opción B: Copiar los archivos
cp ~/vimconfig/.vimrc ~/.vimrc
```

### 2. Instalar vim-plug (gestor de plugins)
```bash
curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
```

### 3. Instalar plugins
Abre Vim y ejecuta:
```
:PlugInstall
```

### 4. Instalar dependencias opcionales
```bash
# Para COC (autocompletado inteligente)
# Node.js requerido
# En Vim: :CocInstall coc-json coc-python coc-tsserver coc-html coc-css

# Para FZF (búsqueda difusa)
# Ya se instala con :PlugInstall, pero necesita fzf binario
# Linux: sudo apt install fzf  /  sudo dnf install fzf  /  sudo pacman -S fzf

# Para iconos en NERDTree/Airline (requiere fuente Nerd Font)
# https://www.nerdfonts.com/font-downloads
```

## ⌨️ Atajos de Teclado Principales

### Navegación de Ventanas
| Tecla | Acción |
|-------|--------|
| `Ctrl+h/j/k/l` | Mover entre ventanas |
| `↑/↓` | Redimensionar ventana horizontal |
| `←/→` | Redimensionar ventana vertical |

### Buffers (Archivos abiertos)
| Tecla | Acción |
|-------|--------|
| `Tab` | Siguiente buffer |
| `Shift+Tab` | Buffer anterior |
| `,bd` | Cerrar buffer actual |

### Búsqueda y Archivos
| Tecla | Acción |
|-------|--------|
| `,f` | Buscar archivos (FZF) |
| `,b` | Listar buffers (FZF) |
| `,g` | Buscar texto (ripgrep) |
| `,n` | Abrir/cerrar NERDTree |
| `,nf` | Encontrar archivo actual en NERDTree |

### Edición
| Tecla | Acción |
|-------|--------|
| `,h` | Limpiar resaltado de búsqueda |
| `Ctrl+s` | Guardar archivo |
| `,ev` | Editar .vimrc |
| `,sv` | Recargar .vimrc |
| `Alt+j/k` | Mover línea arriba/abajo |
| `F2` | Alternar modo paste |

### Git (vim-fugitive)
| Tecla | Acción |
|-------|--------|
| `:Git` | Abrir status de git |
| `:Gdiffsplit` | Ver diff |
| `:Gblame` | Ver blame |
| `:Glog` | Historial de commits |

## 🔧 Personalización

### Configuración Local (por máquina)
Crea `~/.vimrc.local` para configuraciones específicas:
```vim
" Ejemplo ~/.vimrc.local
set number
colorscheme desert
" Configuraciones de trabajo, proxies, etc.
```

### Cambiar Tema de Colores
```vim
" En .vimrc.local o directamente en .vimrc
colorscheme desert     " Otros: morning, evening, koehler, slate, industry
```

### Plugins Adicionales Recomendados
Descomenta en .vimrc y ejecuta `:PlugInstall`:
```vim
" Plug 'scrooloose/nerdcommenter'      " Comentarios mejorados
" Plug 'vim-scripts/ReplaceWithRegister' " Reemplazar con registro
" Plug 'machakann/vim-sandwich'        " Alternativa a surround
" Plug 'tpope/vim-abolish'             " Coerción de palabras
" Plug 'wellle/targets.vim'            " Text objects mejorados
```

## 🐛 Solución de Problemas

### Plugins no se instalan
```vim
:PlugClean    " Eliminar plugins no listados
:PlugUpdate   " Actualizar todos
:PlugUpgrade  " Actualizar vim-plug
```

### COC no funciona
```bash
# Verificar Node.js
node --version  # Debe ser >= 14

# Reinstalar COC
:CocUninstall
:PlugClean
:PlugInstall
:CocInstall coc-json coc-python coc-tsserver
```

### Error de colores en terminal
```vim
" En .vimrc.local
set termguicolors
" O forzar 256 colores
set t_Co=256
```

### NERDTree no muestra iconos
Instala una Nerd Font y configura tu terminal para usarla:
- [Nerd Fonts](https://www.nerdfonts.com/font-downloads)
- En .vimrc: `let g:NERDTreeDirArrowExpandable = '▸'`

## 📚 Recursos Útiles

### Documentación Vim
- `:help` - Ayuda interna
- `:help usr_toc` - Manual de usuario
- `vimtutor` - Tutorial interactivo (ejecuta en terminal)

### Plugins Instalados
| Plugin | Comando Ayuda | Descripción |
|--------|---------------|-------------|
| vim-sensible | `:help sensible` | Configuraciones sensatas |
| vim-surround | `:help surround` | Manipular delimitadores |
| vim-commentary | `:help commentary` | Comentar/descomentar |
| nerdtree | `:help NERDTree` | Explorador de archivos |
| fzf.vim | `:help fzf-vim` | Búsqueda difusa |
| coc.nvim | `:help coc` | Autocompletado LSP |
| airline | `:help airline` | Barra de estado |
| gitgutter | `:help gitgutter` | Señales git en gutter |

### Atajos Vim Esenciales (recordar)
```
Modo Normal:
  gg / G          - Inicio / Final del archivo
  Ctrl+u / Ctrl+d - Media página arriba/abajo
  * / #           - Buscar palabra bajo cursor
  ciw / diw / yiw - Cambiar/borrar/kopiar palabra
  .               - Repetir última acción
  u / Ctrl+r      - Deshacer / Rehacer

Modo Visual:
  v / V / Ctrl+v  - Caracter / Línea / Bloque
  > / <           - Indentar / Desindentar
  =               - Auto-indentar selección

Comandos:
  :w / :q / :wq   - Guardar / Salir / Guardar y salir
  :e archivo      - Abrir archivo
  :bn / :bp       - Buffer siguiente/anterior
  :ls             - Listar buffers
  :split / :vsplit - Dividir ventana
```

## 🔄 Mantenimiento

### Actualizar Todo
```vim
:PlugUpgrade
:PlugUpdate
:CocUpdate
```

### Backup de Configuración
```bash
# Hacer backup
cp ~/.vimrc ~/.vimrc.backup.$(date +%Y%m%d)

# Restaurar
cp ~/.vimrc.backup.YYYYMMDD ~/.vimrc
```

### Sincronizar entre Máquinas
```bash
# Opción 1: Git (recomendado)
cd ~/vimconfig
git init
git add .
git commit -m "Configuración inicial Vim"
# Subir a GitHub/GitLab y clonar en otras máquinas

# Opción 2: Dotfiles con stow
# mkdir -p ~/.dotfiles && mv ~/vimconfig ~/.dotfiles/vim
# cd ~/.dotfiles && stow vim
```

## 📝 Notas Finales

1. **Leader key**: `,` (coma) - configurable en `.vimrc` con `let mapleader = ","`

2. **Codificación**: UTF-8 por defecto

3. **Indentación**: 4 espacios por defecto (2 para web/JS/TS/YAML)

4. **Persistencia**: El historial de deshacer, backups y swaps se guardan en `~/.vim/`

5. **Compatibilidad**: Esta configuración es para **Vim 8.0+** (incluye Neovim)

---

## 🐹 Snippets de Go (Golang)

Los archivos `.go` cargan automáticamente:
- `~/.vim/plugin/go_support.vim` — diccionario de plantillas + función `GoInsert()`
- `~/.vim/ftplugin/go.vim` — mapeos y ajustes de indentación de Go (tabs, `tabstop=4`)

Todos los snippets usan la tecla `\` (mismo líder que c-support). Usan las **mismas teclas que C++**:

| Tecla | Snippet |
|-------|---------|
| `\sif` | `if  { ... }` |
| `\sie` | `if { } else { }` |
| `\sei` | `} else if  { ... }` |
| `\sel` | `else { ... }` |
| `\sw` | `for  { ... }` (equivale a `while`) |
| `\ss` | `switch  { ... }` |
| `\sc` | `case` |
| `\sb` | `{ }` (bloque) |
| `\sfo` | `for i := 0; i < n; i++ { ... }` |
| `\sfr` | `for i, v := range items { ... }` |
| `\im` | `func main() { ... }` |
| `\if` | `func name() { ... }` |
| `\is` | `type Name struct { ... }` |
| `\ipr` | `fmt.Printf("\n")` (cursor dentro de las comillas) |
| `\isc` | `fmt.Scan(&val)` |

Extras propios de Go:

| Tecla | Snippet |
|-------|---------|
| `\se` | `if err != nil { return err }` |
| `\sm` | `func main() { ... }` |
| `\sf` | `func name() { ... }` |
| `\sg` | `go func() { ... }()` |
| `\sd` | `defer` |
| `\sr` / `\so` | for range / for clásico (alias) |
| `\si` | `type Name interface { ... }` |
| `\sh` | `http.HandleFunc("/", ...)` |
| `\shs` | `http.ListenAndServe(":8080", nil)` |
| `\schan` | `ch := make(chan Type, 10)` |
| `\smu` | `var mu sync.Mutex` |
| `\stt` | `func TestName(t *testing.T) { ... }` |
| `\sbm` | `func BenchmarkName(b *testing.B) { ... }` |
| `\sj` | `json.Marshal(v)` |

**Modo visual:** seleccioná líneas y usá `\sif`, `\sw`, `\ss` o `\sg` para envolverlas en la estructura correspondiente.

**Modo insert:** los atajos funcionan también mientras escribís (como en c-support). Escribís `\sif` en medio del código y te inserta el bloque al instante. El paso de `\` + letras usa una tolerancia corta (`timeoutlen=400`) para que responda rápido.

> Los snippets se insertan en la línea actual (o debajo si ya tiene texto) y dejan el cursor en modo insertar donde tenés que escribir.

---

## 🐧 Nota para Raspberry Pi OS

En **Raspberry Pi OS** (Raspbian), la carpeta `/usr/src/` pertenece al usuario `root` y **no permite descomprimir ni escribir sin sudo**. El instalador del plugin **c-support** (c-support.zip) ofrece `/usr/src/` como destino por defecto al ejecutarlo dentro de Vim — **cancelá** si te lo propone.

### Instalación correcta de c-support en RPi OS

```bash
# 1. Descargar el zip en tu carpeta de usuario (NO en /usr/src/)
curl -o ~/c-support.zip https://www.drchip.org/astronaut/vim/c-support/c-support.zip

# 2. Extraerlo en ~/.vim/
unzip ~/c-support.zip -d ~/.vim/

# 3. (Opcional) Configurar plantillas en ~/.vimrc.local
#    Ver sección Personalización arriba
rm ~/c-support.zip
```

Si ya lo extrajiste en `/usr/src/` con root, podés eliminarlo sin afectar nada:
```bash
sudo rm -rf /usr/src/c-support /usr/src/c-support.zip
```

> **¿Por qué ocurre?** En Raspbian, `/usr/src/` está pensado para código fuente del sistema (kernel, drivers), no para configuraciones de usuario. Usa siempre `~/.vim/` — es seguro y no requiere permisos especiales.

---

**¿Problemas?** Revisa `:messages` en Vim para ver errores, o abre un issue en tu repositorio de dotfiles.