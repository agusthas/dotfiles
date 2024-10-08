" Don't try to be vi compatible
set nocompatible

" No backup nor swaps
set nobackup
set noswapfile

" Helps force plugins to load correctly when it is turned back on below
filetype off

" " TODO: Load plugins here (pathogen or vundle)
" if has('unix')
"   if has('mac')
"   else
"     let data_dir = '~/.vim'
"     if empty(glob(data_dir . '/autoload/plug.vim'))
"       silent execute '!curl -fLo '.data_dir.'/autoload/plug.vim --create-dirs  https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
"       autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
"     endif

"     call plug#begin()
"       Plug 'tpope/vim-commentary'
"       Plug 'tpope/vim-surround'
"       Plug 'markonm/traces.vim'
"       Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
"       Plug 'junegunn/fzf.vim'
"     call plug#end()
"     " Map Ctrl + p to open fuzzy find (FZF)
"     nnoremap <c-p> :Files<cr>
"   endif
" endif

" Turn on syntax highlighting
syntax on

" For plugins to load correctly
filetype plugin indent on

nnoremap <SPACE> <Nop>
let mapleader = " "

" Security
set modelines=0

" Show line numbers
set number

" Show file stats
set ruler

" Blink cursor on error instead of beeping (grr)
" set visualbell

" Encoding
set encoding=utf-8

" Whitespace
" set wrap
" set textwidth=79
set formatoptions=tcqrn1
set tabstop=2
set shiftwidth=2
set softtabstop=2
set expandtab
set noshiftround

" Cursor motion
set scrolloff=3
set backspace=indent,eol,start
set matchpairs+=<:> " use % to jump between pairs
runtime! macros/matchit.vim

" Move up/down editor lines
nnoremap j gj
nnoremap k gk

" Allow hidden buffers
set hidden

" Rendering
set ttyfast

" Status bar
set laststatus=2

" Last line
set showmode
set showcmd

" Searching
nnoremap / /\v
vnoremap / /\v
set hlsearch
set incsearch
set ignorecase
set smartcase
set showmatch
map <leader><space> :let @/=''<cr> " clear search

" Textmate holdouts

" Formatting
map <leader>q gqip

" Visualize tabs and newlines
set listchars=tab:▸\ ,eol:¬
" Uncomment this to enable by default:
" set list " To enable by default
" Or use your leader key + l to toggle on/off
map <leader>l :set list!<CR> " Toggle tabs and EOL

" Color scheme (terminal)
set t_Co=256
set background=dark

if has('unix')
  if has('mac')
    silent! colorscheme habamax
  else
    silent! colorscheme elflord
  endif
endif
