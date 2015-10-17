"Required for Vundle

set nocompatible
filetype off

set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()

Plugin 'gmarik/Vundle.vim'

"End of Required
"Vundle Plugins go Here

" The following are examples of different formats supported.
" " Keep Plugin commands between vundle#begin/end.
" " plugin on GitHub repo
" Plugin 'tpope/vim-fugitive'
" " plugin from http://vim-scripts.org/vim/scripts.html
" Plugin 'L9'
" " Git plugin not hosted on GitHub
" Plugin 'git://git.wincent.com/command-t.git'
" " git repos on your local machine (i.e. when working on your own plugin)
" Plugin 'file:///home/gmarik/path/to/plugin'
" " The sparkup vim script is in a subdirectory of this repo called vim.
" " Pass the path to set the runtimepath properly.
" Plugin 'rstacruz/sparkup', {'rtp': 'vim/'}
" " Avoid a name conflict with L9
" Plugin 'user/L9', {'name': 'newL9'}

Plugin 'scrooloose/nerdtree' 
map <F2> :NERDTreeToggle<CR>

Plugin 'jpalardy/vim-slime'
let g:slime_target = "tmux"
let g:slime_python_ipython = 1

"Plugin 'davidhalter/jedi-vim'
"let g:jedi#popup_on_dot = 0

Plugin 'sickill/vim-monokai'

Bundle 'bling/vim-airline'
let g:airline#extensions#tabline#enabled = 1
set laststatus=2 "Need this or else airline online works after making a split
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
let g:airline_theme = 'simple'


Plugin 'kien/ctrlp.vim'
let g:ctrlp_map = '<c-p>'
let g:ctrlp_cmd = 'CtrlP'
let g:ctrlp_custom_ignore = {
 \ 'dir': '\v[\/]\.(git|hg|svn)$',
 \ 'file': '\v\.(pyc)$',
 \ }


Bundle 'ervandew/supertab'
let g:SuperTabDefaultCompletionType = "context" "Use Jedi-vim with supertab

Plugin 'tpope/vim-fugitive'


"End of Vundle plugins

call vundle#end()
filetype plugin indent on

"End of Vundle Section


nmap <leader>l :set list!<CR>

syntax enable
set background=dark
colorscheme monokai

set tabstop=4
set expandtab
set softtabstop=4
set shiftwidth=4
set showmatch
set number
set mouse:a

set foldmethod=indent
set foldlevel=99

"Change leader key to space
let mapleader = "\<Space>"

"Move around windows (splits) easier
map <c-j> <c-w>j
map <c-k> <c-w>k
map <c-h> <c-w>h
map <c-l> <c-w>l


"map the <Esc> key to something easier
imap jk <ESC>
vmap jk <ESC>

"Abandoned buffers are hidden
set hid

"Ignore case when searching
set ignorecase

"When searching, try to be smart about cases
set smartcase

"Highlight search results
set hlsearch

"Make search act like search in modern browsers (?)
set incsearch

"Relative line numbers for easier jumping
set relativenumber 

set timeoutlen=200

"When making a new split, set focus to that split
set splitbelow
set splitright

"Keep a margin of 5 lines to the end of the screen when scrolling
set scrolloff=5

"Highlight angle brackets like other bracket types
set matchpairs+=<:>

"Normal backspace
set backspace=indent,eol,start
