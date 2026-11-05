" =============================================================
"  go_support.vim : snippets de Go (Golang) estilo c-support
"
"  LEE LOS MISMOS ATAJOS QUE c-support (C/C++), traducidos a Go.
"  Tecla <GoLeader> (por defecto "\", igual que c-support).
"
"  Condicionales (igual que C++):
"     \sif  if cond { }            \sie  if { } else { }
"     \sei  else if { }            \sel  else { }
"     \sw   for cond { } (while)   \ss   switch
"     \sc   case                   \sb   { } (bloque)
"     \sfo  for i := 0; i < n; i++ \sfr  for range
"
"  Idioms (igual que C++):
"     \im   func main()            \is   type Name struct { }
"     \if   func name() { }        \ipr  fmt.Printf
"     \isc  fmt.Scan
"
"  Extras propios de Go:
"     \se   if err != nil { return err }
"     \sm   func main()            \sf   func name()
"     \sg   go func() { }()        \sd   defer
"     \sr   for range (alias)      \so   for clásico (alias)
"     \si   interface              \sh   http.HandleFunc
"     \shs  http.ListenAndServe    \schan  make(chan …)
"     \smu  sync.Mutex             \stt  TestName
"     \sbm  BenchmarkName          \sj   json.Marshal
"
"  Visual: seleccioná líneas y usá \sif / \sw / \ss / \sg para
"  envolver la selección en la estructura correspondiente.
" =============================================================

if exists('g:loaded_go_support')
  finish
endif
let g:loaded_go_support = 1

if !exists('g:go_support_mapleader')
  let g:go_support_mapleader = '\'
endif

" -------------------------------------------------------------
"  Definición de snippets
"  Cada entrada:
"    lines  : líneas de la plantilla ('' = línea en blanco)
"             la indentación de cada línea usa TAB literal (Go)
"    cursor : [fila, col] 0-based dentro de la plantilla
"             col = -1  -> primer carácter no blanco de la fila
"             col = -2  -> final del texto de la fila
"    mode   : 'i'  deja en modo insertar, 'n' modo normal
" -------------------------------------------------------------
let s:go = {}

let s:go.main = {
      \ 'lines' : ["func main() {", "", "}"],
      \ 'cursor': [1, -1],
      \ 'mode'  : 'i' }

let s:go.func = {
      \ 'lines' : ["func name() {", "", "}"],
      \ 'cursor': [0, 5],
      \ 'mode'  : 'i' }

let s:go.if = {
      \ 'lines' : ["if  {", "", "}"],
      \ 'cursor': [0, 4],
      \ 'mode'  : 'i' }

let s:go.iferr = {
      \ 'lines' : ["if err != nil {", "\treturn err", "}"],
      \ 'cursor': [1, -2],
      \ 'mode'  : 'i' }

let s:go.ifelse = {
      \ 'lines' : ["if  {", "", "} else {", "", "}"],
      \ 'cursor': [0, 4],
      \ 'mode'  : 'i' }

let s:go.elseif = {
      \ 'lines' : ["} else if  {", "", "}"],
      \ 'cursor': [0, 10],
      \ 'mode'  : 'i' }

let s:go.else = {
      \ 'lines' : ["else {", "", "}"],
      \ 'cursor': [1, -1],
      \ 'mode'  : 'i' }

let s:go.forrange = {
      \ 'lines' : ["for i, v := range items {", "", "}"],
      \ 'cursor': [1, -1],
      \ 'mode'  : 'i' }

let s:go.fori = {
      \ 'lines' : ["for i := 0; i < n; i++ {", "", "}"],
      \ 'cursor': [1, -1],
      \ 'mode'  : 'i' }

let s:go.while = {
      \ 'lines' : ["for  {", "", "}"],
      \ 'cursor': [0, 4],
      \ 'mode'  : 'i' }

let s:go.switch = {
      \ 'lines' : ["switch  {", "", "}"],
      \ 'cursor': [0, 7],
      \ 'mode'  : 'i' }

let s:go.case = {
      \ 'lines' : ["case "],
      \ 'cursor': [0, 5],
      \ 'mode'  : 'i' }

let s:go.block = {
      \ 'lines' : ["{", "", "}"],
      \ 'cursor': [1, -1],
      \ 'mode'  : 'i' }

let s:go.struct = {
      \ 'lines' : ["type Name struct {", "\tField Type", "}"],
      \ 'cursor': [0, 5],
      \ 'mode'  : 'i' }

let s:go.interface = {
      \ 'lines' : ["type Name interface {", "\tMethod()", "}"],
      \ 'cursor': [0, 5],
      \ 'mode'  : 'i' }

let s:go.goroutine = {
      \ 'lines' : ["go func() {", "", "}()"],
      \ 'cursor': [1, -1],
      \ 'mode'  : 'i' }

let s:go.defer = {
      \ 'lines' : ["defer "],
      \ 'cursor': [0, -2],
      \ 'mode'  : 'i' }

let s:go.handler = {
      \ 'lines' : ["http.HandleFunc(\"/\", func(w http.ResponseWriter, r *http.Request) {", "", "})"],
      \ 'cursor': [1, -1],
      \ 'mode'  : 'i' }

let s:go.httpserver = {
      \ 'lines' : ["http.ListenAndServe(\":8080\", nil)"],
      \ 'cursor': [0, -2],
      \ 'mode'  : 'n' }

let s:go.channel = {
      \ 'lines' : ["ch := make(chan Type, 10)"],
      \ 'cursor': [0, 16],
      \ 'mode'  : 'i' }

let s:go.mutex = {
      \ 'lines' : ["var mu sync.Mutex"],
      \ 'cursor': [0, 4],
      \ 'mode'  : 'i' }

let s:go.test = {
      \ 'lines' : ["func TestName(t *testing.T) {", "", "}"],
      \ 'cursor': [0, 5],
      \ 'mode'  : 'i' }

let s:go.benchmark = {
      \ 'lines' : ["func BenchmarkName(b *testing.B) {", "", "}"],
      \ 'cursor': [0, 5],
      \ 'mode'  : 'i' }

let s:go.json = {
      \ 'lines' : ["json.Marshal(v)"],
      \ 'cursor': [0, 13],
      \ 'mode'  : 'i' }

let s:go.printf = {
      \ 'lines' : ["fmt.Printf(\"\\n\")"],
      \ 'cursor': [0, 12],
      \ 'mode'  : 'i' }

let s:go.scanf = {
      \ 'lines' : ["fmt.Scan(&val)"],
      \ 'cursor': [0, 9],
      \ 'mode'  : 'i' }

" -------------------------------------------------------------
"  GoInsert(name) : inserta el snippet 'name' en la línea actual
" -------------------------------------------------------------
function! GoInsert(name) abort
  if !has_key(s:go, a:name)
    echohl ErrorMsg
    echomsg 'go_support: snippet desconocido: ' . a:name
    echohl None
    return
  endif

  let s_def  = s:go[a:name]
  let lines  = s_def['lines']
  let [crow, ccol] = s_def['cursor']
  let insmode = get(s_def, 'mode', 'n')

  let base = indent('.')
  let ln   = line('.')
  let l0   = getline('.')

  if l0 =~# '^\s*$'
    " Línea actual vacía: se reemplaza por la primera del snippet
    call setline(ln, repeat(' ', base) . lines[0])
  else
    " Línea actual con texto: insertar después
    call append(ln, repeat(' ', base) . lines[0])
    let ln += 1
  endif

  let i = 1
  while i < len(lines)
    call append(ln, repeat(' ', base) . lines[i])
    let ln += 1
    let i += 1
  endwhile

  " Posición del cursor dentro de la plantilla insertada
  let r = ln - (len(lines) - 1 - crow)
  let line = getline(r)
  if ccol >= 0
    " columna fija: sumar la indentación que precede al snippet
    let col = ccol + 1 + base
  elseif ccol == -1
    " primer carácter no blanco
    let m = matchend(line, '\S')
    let col = (m >= 0) ? m + 1 : 1
  else
    " final del texto de la fila
    let col = len(line) + 1
  endif
  call cursor(r, col)

  if insmode ==# 'i'
    startinsert
  endif
endfunction

" -------------------------------------------------------------
"  GoWrapVisual(header, footer) : envuelve la selección visual
"  entre header y footer, dejando el cursor en el placeholder
"  (justo antes de '{'). Ejemplos:
"     \sif  -> GoWrapVisual('if  {', '}')
"     \sw   -> GoWrapVisual('for  {', '}')
"     \ss   -> GoWrapVisual('switch  {', '}')
"     \sg   -> GoWrapVisual('go func() {', '}()')
" -------------------------------------------------------------
function! GoWrapVisual(header, footer) abort
  let [ln1, ln2] = [line("'<"), line("'>")]
  let base = indent(ln1)
  let sel = getline(ln1, ln2)
  execute ln1 . ',' . ln2 . 'delete'
  call append(ln1 - 1, [repeat(' ', base) . a:header]
        \ + map(copy(sel), {_, l -> repeat(' ', base) . l})
        \ + [repeat(' ', base) . a:footer])
  call cursor(ln1, len(a:header))
  startinsert
endfunction