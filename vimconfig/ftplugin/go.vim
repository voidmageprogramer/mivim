" go.vim : ajustes específicos de archivos Go y mapeos de snippets
"
" Los snippets los define ~/.vim/plugin/go_support.vim. Usan las
" MISMAS teclas que c-support (C/C++):
"
"   Condicionales                  Idioms (C++ -> Go)
"   \sif  if { }                   \im  func main
"   \sie  if { } else { }          \if  func name
"   \sei  else if { }              \is  struct
"   \sel  else { }                 \ipr fmt.Printf
"   \sw   for cond { } (while)     \isc fmt.Scan
"   \ss   switch
"   \sc   case                     Extras de Go
"   \sb   { }                      \se  if err != nil
"   \sfo  for clásico              \sm  func main
"   \sfr  for range                \sf  func name
"                                  \sg  goroutine / (visual wrap)
"                                  \sd  defer, \sr range, \so for classic
"                                  \si  interface, \sh handler
"                                  \shs server, \schan channel, \smu mutex
"                                  \stt test, \sbm benchmark, \sj json
"
"   Visual: \sif / \sw / \ss / \sg envuelven la selección.

setlocal tabstop=4 shiftwidth=4 softtabstop=4 noexpandtab

if exists('g:loaded_go_support')
  let s:go_maps = {
        \ 'sm'  : ['main'],
        \ 'sf'  : ['func'],
        \ 'se'  : ['iferr'],
        \ 'sif' : ['if'],
        \ 'sie' : ['ifelse'],
        \ 'sei' : ['elseif'],
        \ 'sel' : ['else'],
        \ 'sfo' : ['fori'],
        \ 'sfr' : ['forrange'],
        \ 'sr'  : ['forrange'],
        \ 'so'  : ['fori'],
        \ 'sw'  : ['while'],
        \ 'ss'  : ['switch'],
        \ 'sc'  : ['case'],
        \ 'sb'  : ['block'],
        \ 'si'  : ['interface'],
        \ 'sg'  : ['goroutine'],
        \ 'sd'  : ['defer'],
        \ 'sh'  : ['handler'],
        \ 'shs' : ['httpserver'],
        \ 'schan': ['channel'],
        \ 'smu' : ['mutex'],
        \ 'stt' : ['test'],
        \ 'sbm' : ['benchmark'],
        \ 'sj'  : ['json'],
        \ 'if'  : ['func'],
        \ 'im'  : ['main'],
        \ 'is'  : ['struct'],
        \ 'ipr' : ['printf'],
        \ 'isc' : ['scanf'],
        \ }
  for [s:key, s:val] in items(s:go_maps)
    execute 'nnoremap <buffer> <silent> ' . g:go_support_mapleader . s:key
          \ . ' :call GoInsert(''' . s:val[0] . ''')<CR>'
    execute 'inoremap <buffer> <silent> ' . g:go_support_mapleader . s:key
          \ . ' <C-\><C-o>:call GoInsert(''' . s:val[0] . ''')<CR>'
  endfor
  unlet s:key s:val

  " Visual: envolver la selección en una estructura
  let s:go_visual = {
        \ 'sif' : ['if  {', '}'],
        \ 'sw'  : ['for  {', '}'],
        \ 'ss'  : ['switch  {', '}'],
        \ 'sg'  : ['go func() {', '}()'],
        \ }
  for [s:key, s:val] in items(s:go_visual)
    execute 'xnoremap <buffer> <silent> ' . g:go_support_mapleader . s:key
          \ . ' :call GoWrapVisual(''' . s:val[0] . ''','''
          \ . s:val[1] . ''')<CR><Esc>'
  endfor
  unlet s:key s:val
endif