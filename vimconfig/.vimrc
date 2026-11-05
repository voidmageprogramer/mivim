" Vim Configuration File
" =======================

" Basic Settings
set nocompatible              " Disable Vi compatibility mode
set encoding=utf-8            " Set encoding to UTF-8
set fileencoding=utf-8        " Set file encoding to UTF-8
set number                    " Show line numbers
set relativenumber            " Show relative line numbers
set cursorline                " Highlight current line
set showcmd                   " Show command in status bar
set wildmenu                  " Enhanced command completion
set lazyredraw                " Don't redraw while executing macros
set showmatch                 " Highlight matching brackets
set incsearch                 " Incremental search
set hlsearch                  " Highlight search results
set ignorecase                " Case insensitive search
set smartcase                 " Case sensitive if uppercase used
set autoindent                " Auto indent new lines
set smartindent               " Smart indent
set tabstop=4                 " Tab width
set shiftwidth=4              " Indent width
set expandtab                 " Use spaces instead of tabs
set softtabstop=4             " Spaces per tab when editing
set wrap                      " Wrap long lines
set linebreak                 " Break at word boundaries
set scrolloff=8               " Keep 8 lines above/below cursor
set sidescrolloff=8           " Keep 8 columns left/right of cursor
set backspace=indent,eol,start " Allow backspace over everything
set clipboard=unnamedplus     " Use system clipboard
set mouse=a                   " Enable mouse support
set history=1000              " Command history size
set undolevels=1000           " Undo levels
set wildignore=*.o,*.obj,*~   " Ignore compiled files
set title                     " Set terminal title
set titlestring=%F            " Show full path in title

" Visual Settings
syntax on                     " Enable syntax highlighting
filetype on                   " Enable filetype detection
filetype plugin on            " Enable filetype plugins
filetype indent on            " Enable filetype-specific indenting
set termguicolors             " Enable 24-bit colors (if terminal supports it)
set background=dark           " Assume dark background
colorscheme default           " Default colorscheme (change as needed)

" Status Line
set laststatus=2              " Always show status line
set statusline=%F%m%r%h%w\ [FORMAT=%{&ff}]\ [TYPE=%Y]\ [ASCII=\%03.3b]\ [HEX=\%02.2B]\ [POS=%04l,%04v]\ [%p%%]\ [LEN=%L]

" Key Mappings
let mapleader = ","           " Set leader key to comma

" Better window navigation
nnoremap <C-h> <C-w>h
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-l> <C-w>l

" Resize windows with arrows
nnoremap <Up> :resize +2<CR>
nnoremap <Down> :resize -2<CR>
nnoremap <Left> :vertical resize -2<CR>
nnoremap <Right> :vertical resize +2<CR>

" Buffer navigation
nnoremap <Tab> :bnext<CR>
nnoremap <S-Tab> :bprevious<CR>
nnoremap <leader>bd :bdelete<CR>

" Clear search highlighting
nnoremap <leader>h :nohlsearch<CR>

" Save with Ctrl+S
nnoremap <C-s> :w<CR>
inoremap <C-s> <Esc>:w<CR>a

" Quick edit/reload vimrc
nnoremap <leader>ev :vsplit $MYVIMRC<CR>
nnoremap <leader>sv :source $MYVIMRC<CR>

" Better indenting in visual mode
vnoremap < <gv
vnoremap > >gv

" Move lines up/down
nnoremap <A-j> :m .+1<CR>==
nnoremap <A-k> :m .-2<CR>==
inoremap <A-j> <Esc>:m .+1<CR>==gi
inoremap <A-k> <Esc>:m .-2<CR>==gi
vnoremap <A-j> :m '>+1<CR>gv=gv
vnoremap <A-k> :m '<-2<CR>gv=gv

" Plugins (using vim-plug)
" ========================
" Install vim-plug first: curl -fLo ~/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

call plug#begin('~/.vim/plugged')

" Essential plugins
Plug 'tpope/vim-sensible'           " Sensible defaults
Plug 'tpope/vim-surround'           " Surround text objects
Plug 'tpope/vim-commentary'         " Comment/uncomment lines
Plug 'tpope/vim-repeat'             " Enable repeat for plugins
Plug 'tpope/vim-unimpaired'         " Pairs of handy bracket mappings
Plug 'tpope/vim-eunuch'             " UNIX helpers
Plug 'tpope/vim-fugitive'           " Git wrapper
Plug 'tpope/vim-rhubarb'            " GitHub integration for fugitive

" UI/Appearance
Plug 'vim-airline/vim-airline'      " Status line
Plug 'vim-airline/vim-airline-themes'
Plug 'ryanoasis/vim-devicons'       " File icons

" File navigation
Plug 'preservim/nerdtree'           " File explorer
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'

" Editing enhancements
Plug 'jiangmiao/auto-pairs'         " Auto close brackets/quotes
Plug 'tpope/vim-endwise'            " Auto add end in Ruby/Lua/etc
Plug 'editorconfig/editorconfig-vim' " EditorConfig support

" Language support
Plug 'sheerun/vim-polyglot'         " Syntax highlighting for many languages

" Completion
Plug 'neoclide/coc.nvim', {'branch': 'release'}  " Intellisense engine

" Git signs
Plug 'airblade/vim-gitgutter'       " Show git diff in sign column

call plug#end()

" Plugin Configurations
" =====================

" NERDTree
let NERDTreeShowHidden=1
nnoremap <leader>n :NERDTreeToggle<CR>
nnoremap <leader>nf :NERDTreeFind<CR>

" Airline
let g:airline#extensions#tabline#enabled = 1
let g:airline_theme = 'dark'
let g:airline_powerline_fonts = 1

" FZF
nnoremap <leader>f :Files<CR>
nnoremap <leader>b :Buffers<CR>
nnoremap <leader>g :Rg<CR>

" GitGutter
let g:gitgutter_enabled = 1
let g:gitgutter_map_keys = 0
nmap ]h <Plug>(GitGutterNextHunk)
nmap [h <Plug>(GitGutterPrevHunk)

" COC (completion)
" Use Tab for completion navigation
inoremap <expr> <Tab> pumvisible() ? "\<C-n>" : "\<Tab>"
inoremap <expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>"
inoremap <expr> <CR> pumvisible() ? "\<C-y>" : "\<CR>"

" Filetype-specific settings
" ==========================

" Python
autocmd FileType python setlocal tabstop=4 shiftwidth=4 expandtab

" JavaScript/TypeScript
autocmd FileType javascript,typescript,json setlocal tabstop=2 shiftwidth=2 expandtab

" HTML/CSS
autocmd FileType html,css,scss setlocal tabstop=2 shiftwidth=2 expandtab

" Go
autocmd FileType go setlocal tabstop=4 shiftwidth=4 noexpandtab

" YAML
autocmd FileType yaml setlocal tabstop=2 shiftwidth=2 expandtab

" Markdown
autocmd FileType markdown setlocal spell textwidth=80

" Git commit messages
autocmd FileType gitcommit setlocal spell textwidth=72

" Auto commands
" ===============

" Highlight yanked text
augroup highlight_yank
    autocmd!
    autocmd TextYankPost * silent! lua vim.highlight.on_yank({higroup='IncSearch', timeout=200})
augroup END

" Return to last edit position when opening files
augroup last_position
    autocmd!
    autocmd BufReadPost *
        \ if line("'\"") > 0 && line("'\"") <= line("$") |
        \   exe "normal! g`\"" |
        \ endif
augroup END

" Auto-save on focus lost
augroup auto_save
    autocmd!
    autocmd FocusLost * :wa
augroup END

" Create directories when saving
augroup create_dirs
    autocmd!
    autocmd BufWritePre * call mkdir(expand('<afile>:p:h'), 'p')
augroup END

" Remove trailing whitespace on save
autocmd BufWritePre * :%s/\s\+$//e

" ================
" Custom Functions
" ================

" Toggle relative line numbers
function! ToggleRelativeNumber()
    if &relativenumber
        set norelativenumber
    else
        set relativenumber
    endif
endfunction
nnoremap <leader>rn :call ToggleRelativeNumber()<CR>

" Toggle paste mode
set pastetoggle=<F2>

" ================
" Local overrides (create ~/.vimrc.local for machine-specific config)
" ================
if filereadable(expand("~/.vimrc.local"))
    source ~/.vimrc.local
endif