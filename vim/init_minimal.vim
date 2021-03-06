" Vim Plug
let domainname = tolower(substitute(system('hostname -d'), '\n', '', ''))

if domainname  == "millennium.berkeley.edu"
    call plug#begin("/data/yosef/users/david.detomaso/.nvim/plugged")
else
    call plug#begin()
endif

Plug 'scrooloose/nerdtree', { 'on': 'NERDTreeToggle' }
map <F2> :NERDTreeToggle<CR>
let NERDTreeQuitOnOpen = 1

Plug 'jpalardy/vim-slime'
let g:slime_target = "tmux"
let g:slime_python_ipython = 1

"Colorscheme plugins!
Plug 'sickill/vim-monokai'
Plug 'geetarista/ego.vim'
Plug 'antlypls/vim-colors-codeschool'
Plug 'tomasr/molokai'
Plug 'zeis/vim-kolor'
Plug 'chriskempson/base16-vim'

"Terminal Colorschemes
Plug 'scwood/vim-hybrid'
Plug 'gummesson/stereokai.vim'

" Better text targets
Plug 'wellle/targets.vim'

call plug#end()

"Change leader key to space
let mapleader = "\<Space>"

set background=dark
colorscheme molokai


set tabstop=4
set expandtab
set softtabstop=4
set shiftwidth=4
set showmatch
set number

set foldmethod=indent
set foldlevel=99

set linebreak "Break lines (when on) on word

"Some leader shortcuts for location list
"nnoremap <Leader>l :lopen<cr>
"nnoremap <Leader>k :lclose<cr>

"Move around windows (splits) easier
nnoremap <c-j> <c-w>j
nnoremap <c-k> <c-w>k
nnoremap <c-h> <c-w>h
nnoremap <c-l> <c-w>l

"map the <Esc> key to something easier
imap jk <ESC>

"Abandoned buffers are hidden
set hid

"Ignore case when searching
set ignorecase

"When searching, try to be smart about cases
set smartcase

"Relative line numbers for easier jumping
set relativenumber 

set timeoutlen=500

"When making a new split, set focus to that split
set splitbelow
set splitright

"Keep a margin of 5 lines to the end of the screen when scrolling
set scrolloff=5

"Highlight angle brackets like other bracket types
set matchpairs+=<:>

"Correct fonts for powerline/airline
set encoding=utf-8

"Use the system clipboard by default
set clipboard=unnamed

"Remap H and L (top, bottom of screen) to (left, right of line)
nnoremap H ^
nnoremap L $
vnoremap H ^
vnoremap L g_

"Don't yank to default register when changing something
nnoremap c "xc
xnoremap c "xc

" Windows resizing using arrow keys
nnoremap <silent> <C-Left> :vertical resize +1<CR>
nnoremap <silent> <C-Right> :vertical resize -1<CR>
nnoremap <silent> <C-Up> :resize +1<CR>
nnoremap <silent> <C-Down> :resize -1<CR>

" Switch buffers easier
nnoremap <silent> <C-N> :bn<CR>
nnoremap <silent> <C-P> :bp<CR>

" Don't wrap text lines (feels like I set this too much myself)
set nowrap

" Python Specific
" Use autopep8 for autocorrecting
au FileType python setlocal formatprg=autopep8\ -

" Get rid of bells
set noeb
set vb
set t_vb=

" Don't lose selection when shifting text in visual mode
xnoremap < <gv
xnoremap > >gv

" Options for Latex files
autocmd FileType tex setlocal spell wrap
