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

" Git
Plug 'tpope/vim-fugitive'
Plug 'airblade/vim-gitgutter'

" Status Line
Plug 'vim-airline/vim-airline'
let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#whitespace#enabled = 0
let g:airline#estension#branch#enabled = 1
if !exists('g:airline_symbols')
    let g:airline_symbols = {}
endif
" new vim-powerline symbols
let g:airline_left_sep = ''
let g:airline_left_alt_sep = ''
let g:airline_right_sep = ''
let g:airline_right_alt_sep = ''
let g:airline_symbols.branch = ''
let g:airline_symbols.readonly = ''
let g:airline_symbols.linenr = ''
" old vim-powerline symbols
" let g:airline_left_sep = '⮀'
" let g:airline_left_alt_sep = '⮁'
" let g:airline_right_sep = '⮂'
" let g:airline_right_alt_sep = '⮃'
" let g:airline_symbols.branch = '⭠'
" let g:airline_symbols.readonly = '⭤'
" let g:airline_symbols.linenr = '⭡'
let g:airline#extensions#tabline#left_sep = ''
let g:airline#extensions#tabline#left_alt_sep = ''
let g:airline#extensions#tabline#right_sep = ''
let g:airline#extensions#tabline#right_alt_sep = ''

Plug 'vim-airline/vim-airline-themes'
let g:airline_theme = 'simple'

Plug 'kien/ctrlp.vim'
let g:ctrlp_map = '<c-p>'
let g:ctrlp_cmd = 'CtrlP'
let g:ctrlp_custom_ignore = {
 \ 'dir': '\v[\/]\.(git|hg|svn)$',
 \ 'file': '\v\.(pyc)$',
 \ }

" Syntax Checking
Plug 'neomake/neomake'
let g:neomake_python_enabled_makers = ['flake8']
autocmd! BufWritePost * Neomake

" Autocomplete
function! DoRemote(arg)
  UpdateRemotePlugins
endfunction
Plug 'Shougo/deoplete.nvim', { 'do': function('DoRemote') }
let g:deoplete#enable_at_startup = 1

" use tab-complete for deoplete
inoremap <expr><tab> pumvisible() ? "\<c-n>" : "\<tab>"

" Autocomplete for Python
Plug 'zchee/deoplete-jedi'

" Python Indenting
Plug 'hynek/vim-python-pep8-indent'

" Python text-objects
Plug 'michaeljsmith/vim-indent-object'

" Track the engine.
Plug 'SirVer/ultisnips'

" Snippets are separated from the engine. Add this if you want them:
Plug 'honza/vim-snippets'

" Trigger configuration. Do not use <tab> if you use https://github.com/Valloric/YouCompleteMe.
let g:UltiSnipsExpandTrigger="<c-j>"
let g:UltiSnipsJumpForwardTrigger="<c-b>"
let g:UltiSnipsJumpBackwardTrigger="<c-z>"

" If you want :UltiSnipsEdit to split your window.
let g:UltiSnipsEditSplit="vertical"

" For Python, Numpy style documentation
let g:ultisnips_python_style="numpy"

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
