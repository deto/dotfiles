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

"Plugin 'jpalardy/vim-slime'
"let g:slime_target = "tmux"
"let g:slime_python_ipython = 1

Plugin 'ivanov/vim-ipython'

Plugin 'davidhalter/jedi-vim'
let g:jedi#popup_on_dot = 0

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


"Move around windows (splits) easier
map <c-j> <c-w>j
map <c-k> <c-w>k
map <c-h> <c-w>h
map <c-l> <c-w>l


"map the <Esc> key to something easier
imap jk <ESC>
vmap jk <ESC>
"highlight Pmenu ctermbg=DarkRed ctermfg=LightGray gui=bold
"highlight PmenuSel ctermbg=LightGray ctermfg=DarkRed gui=bold

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

"Normal Backspace
set backspace=indent,eol,start

if has('gui_running')
    set guifont=Inconsolata-g_for_Powerline:h11:cANSI
endif

"Correct fonts for powerline/airline
set encoding=utf-8

"Use the system clipboard by default
set clipboard=unnamed

"Fix GVIM window resizing when making a vertical split
"When you create a vertical split, a left-handed scrollbar is added.  This
"causes window resize and knocks the window out of it's position if it's
"snapped
set guioptions-=L "Don't add left-hand scrollbar on split 
set guioptions-=R "Dont' add right-hand scrollbar on split
set guioptions+=l "Enable Left-hand scrollbar always
set guioptions+=r "Enable right-hand scrollbar always

