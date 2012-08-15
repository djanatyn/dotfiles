""" =======================
""" djanatyn's vim config
""" =======================
""" feel free to debug or use, or whatever.

"" --------------
"" visual options
"" --------------
" set font
set guifont=Ubuntu\ Mono\ 12

" syntax highlighting
syntax on
colorscheme molokai

" disable gui options
set guioptions=

"" ----------------
"" navigation stuff
"" ----------------
" window navigation
nnoremap <C-h> <C-w>h
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-l> <C-w>l

" buffer navigation
nnoremap <Tab> :bn<CR>
nnoremap <S-Tab> :bp<CR>

" Y yanks till end of line
map Y y$

" set line numbers (relative)
set relativenumber

" highlight when searching
set incsearch
set hlsearch
autocmd insertenter * :let @/=""
autocmd insertleave * :let @/=""

" Q repeats macro a
map Q @a

" map jk to escape
inoremap jk <Esc>
"" ----------
"" misc stuff
"" ----------
" spaces, no tabs
set expandtab
" set 'tab' size
set shiftwidth=2
set softtabstop=2
set tabstop=2

" set indent
set autoindent

" make regex not crazy
nnoremap / /\v
vnoremap / /\v
set ignorecase
set smartcase
set gdefault
set incsearch
set showmatch

" wildmenu
set wildmenu
set wildmode=longest,list

" visual bell
set visualbell

set ruler

" allow buffers to be hidden
set hidden

" CtrlP
set runtimepath^=~/.vim/bundle/ctrlp.vim

" leader key
let mapleader = ","

" leader key functions
nnoremap <leader>q :cq<CR>
nnoremap <leader>s :w<CR>
nnoremap <leader>v :e ~/.vimrc<CR>
nnoremap <leader>e :<C-p><CR>

" quicker ex mode commands
nnoremap ; :
