"Change leader key to space
let mapleader = "\<Space>"


call plug#begin()

Plug 'scrooloose/nerdtree', { 'on': 'NERDTreeToggle' }
map <F2> :NERDTreeToggle<CR>
let NERDTreeQuitOnOpen = 1

Plug 'jpalardy/vim-slime'
let g:slime_target = "tmux"
let g:slime_python_ipython = 1
let g:slime_preserve_curpos = 1
let g:slime_paste_file = tempname()

"Colorscheme plugins!
Plug 'sickill/vim-monokai'
Plug 'geetarista/ego.vim'
Plug 'antlypls/vim-colors-codeschool'
Plug 'tomasr/molokai'
Plug 'zeis/vim-kolor'
Plug 'chriskempson/base16-vim'
Plug 'patstockwell/vim-monokai-tasty'

"Terminal Colorschemes
Plug 'scwood/vim-hybrid'
Plug 'gummesson/stereokai.vim'

" Status Line
" Plug 'vim-airline/vim-airline'
" let g:airline#extensions#tabline#enabled = 1
" let g:airline#extensions#whitespace#enabled = 0
" let g:airline#estension#branch#enabled = 1
" if !exists('g:airline_symbols')
"     let g:airline_symbols = {}
" endif
" " new vim-powerline symbols
" let g:airline_left_sep = ''
" let g:airline_left_alt_sep = ''
" let g:airline_right_sep = ''
" let g:airline_right_alt_sep = ''
" let g:airline_symbols.branch = ''
" let g:airline_symbols.readonly = ''
" let g:airline_symbols.linenr = ''
" " old vim-powerline symbols
" " let g:airline_left_sep = '⮀'
" " let g:airline_left_alt_sep = '⮁'
" " let g:airline_right_sep = '⮂'
" " let g:airline_right_alt_sep = '⮃'
" " let g:airline_symbols.branch = '⭠'
" " let g:airline_symbols.readonly = '⭤'
" " let g:airline_symbols.linenr = '⭡'
" let g:airline#extensions#tabline#left_sep = ''
" let g:airline#extensions#tabline#left_alt_sep = ''
" let g:airline#extensions#tabline#right_sep = ''
" let g:airline#extensions#tabline#right_alt_sep = ''
" 
" Plug 'vim-airline/vim-airline-themes'
" let g:airline_theme = 'simple'

Plug 'itchyny/lightline.vim'
let g:lightline = {
            \ 'colorscheme': 'jellybeans',
            \ 'separator': { 'left': '', 'right': ''},
            \ 'subseparator': { 'left': '', 'right': ''},
            \}

Plug 'kien/ctrlp.vim'
let g:ctrlp_map = '<c-p>'
let g:ctrlp_cmd = 'CtrlP'
let g:ctrlp_custom_ignore = {
 \ 'dir': '\v[\/]\.(git|hg|svn)$',
 \ 'file': '\v\.(pyc)$',
 \ }

Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'
nmap <Leader>f :GFiles<CR>
nmap <Leader>F :Files<CR>
nmap <Leader>t :Tags<CR>
nmap <Leader>b :Buffers<CR>

" Plug 'ludovicchabant/vim-gutentags'

" Python Indenting
Plug 'hynek/vim-python-pep8-indent'

" Python text-objects
Plug 'michaeljsmith/vim-indent-object'

" Good searching of files with Ack/Ag
Plug 'mileszs/ack.vim'
let g:ackprg = 'ag --vimgrep'

" Better text targets
" Commenting this as it breaks macros :(
" Plug 'wellle/targets.vim'


" ALE
Plug 'w0rp/ale'
let g:ale_linters = {
\   'python': ['flake8'],
\   'javascript': ['eslint'],
\   'r': ['lintr'],
\}
let g:ale_r_lintr_options = 'lintr::with_defaults(absolute_path_linter = NULL, camel_case_linter = NULL, closed_curly_linter = NULL, object_name_linter = NULL)'

Plug 'neoclide/coc.nvim', {'branch': 'release', 'do': ':CocInstall coc-python'}

Plug 'christoomey/vim-tmux-navigator'

call plug#end()

set background=dark
colorscheme vim-monokai-tasty


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
"set relativenumber 

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
" au FileType python setlocal formatprg=autopep8\ --aggressive\ -
au FileType python setlocal formatprg=black\ -l\ 80\ -q\ -

" Get rid of bells
set noeb
set vb
set t_vb=

" Don't lose selection when shifting text in visual mode
xnoremap < <gv
xnoremap > >gv

" Options for Latex files
autocmd FileType tex setlocal spell wrap

set breakindent

" Quickfix mappings (from tpope/vim-unimpaired)
nnoremap ]q :cnext<CR>
nnoremap [q :cprevious<CR>
nnoremap ]Q :clast<CR>
nnoremap [Q :cfirst<CR>

nnoremap ]l :lnext<CR>
nnoremap [l :lprevious<CR>
nnoremap ]L :llast<CR>
nnoremap [L :lfirst<CR>

" Better indenting for R (built-in Vim option)
let r_indent_align_args = 0

" No case insensitive search in the wild menu
set wildignorecase

" Run cell for vim-slime
function! SendCell(pattern)
    let start_line = search(a:pattern, 'bnW')

    if start_line
        let start_line = start_line + 1
    else
        let start_line = 1
    endif

    let stop_line = search(a:pattern, 'nW')
    if stop_line
        let stop_line = stop_line - 1
    else
        let stop_line = line('$')
    endif

    call slime#send_range(start_line, stop_line)
endfunction

" Custom vim-slime mappings
let g:slime_no_mappings = 1
xmap <c-c><c-c> <Plug>SlimeRegionSend
nmap <c-c><c-c> :<c-u>call SendCell('^#.\+%%')<cr>
nmap <c-c>v     <Plug>SlimeConfig

" Turn off search highligting more easily
nmap <silent> <cr> :nohl<cr>

" Expand spaces around an = sign
nmap <Space><Space> hf=i<space><esc>la<space><esc>

" ###################################################
" Everything below this is for coc.nvim
" ###################################################

" if hidden is not set, TextEdit might fail.
set hidden

" Some servers have issues with backup files, see #649
set nobackup
set nowritebackup

" Better display for messages
set cmdheight=2

" You will have bad experience for diagnostic messages when it's default 4000.
set updatetime=300

" don't give |ins-completion-menu| messages.
set shortmess+=c

" always show signcolumns
set signcolumn=yes

" Use tab for trigger completion with characters ahead and navigate.
" Use command ':verbose imap <tab>' to make sure tab is not mapped by other plugin.
inoremap <silent><expr> <TAB>
      \ pumvisible() ? "\<C-n>" :
      \ <SID>check_back_space() ? "\<TAB>" :
      \ coc#refresh()
inoremap <expr><S-TAB> pumvisible() ? "\<C-p>" : "\<C-h>"

function! s:check_back_space() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction

" Use <c-space> to trigger completion.
inoremap <silent><expr> <c-space> coc#refresh()

" Use <cr> to confirm completion, `<C-g>u` means break undo chain at current position.
" Coc only does snippet and additional edit on confirm.
inoremap <expr> <cr> pumvisible() ? "\<C-y>" : "\<C-g>u\<CR>"

" Use `[c` and `]c` to navigate diagnostics
nmap <silent> [c <Plug>(coc-diagnostic-prev)
nmap <silent> ]c <Plug>(coc-diagnostic-next)

" Remap keys for gotos
nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)

" Use K to show documentation in preview window
nnoremap <silent> K :call <SID>show_documentation()<CR>

function! s:show_documentation()
  if (index(['vim','help'], &filetype) >= 0)
    execute 'h '.expand('<cword>')
  else
    call CocAction('doHover')
  endif
endfunction

" Highlight symbol under cursor on CursorHold
autocmd CursorHold * silent call CocActionAsync('highlight')

" Remap for rename current word
nmap <leader>rn <Plug>(coc-rename)

" Remap for format selected region
" xmap <leader>f  <Plug>(coc-format-selected)
" nmap <leader>f  <Plug>(coc-format-selected)

augroup mygroup
  autocmd!
  " Setup formatexpr specified filetype(s).
  autocmd FileType typescript,json setl formatexpr=CocAction('formatSelected')
  " Update signature help on jump placeholder
  autocmd User CocJumpPlaceholder call CocActionAsync('showSignatureHelp')
augroup end

" Remap for do codeAction of selected region, ex: `<leader>aap` for current paragraph
xmap <leader>a  <Plug>(coc-codeaction-selected)
nmap <leader>a  <Plug>(coc-codeaction-selected)

" Remap for do codeAction of current line
nmap <leader>ac  <Plug>(coc-codeaction)
" Fix autofix problem of current line
nmap <leader>qf  <Plug>(coc-fix-current)

" Use <tab> for select selections ranges, needs server support, like: coc-tsserver, coc-python
" <deto> I disabled this because it breaks ctrl-i since tab = ctrl-i for
" some reason
" nmap <silent> <TAB> <Plug>(coc-range-select)
" xmap <silent> <TAB> <Plug>(coc-range-select)
" xmap <silent> <S-TAB> <Plug>(coc-range-select-backword)


" Use `:Format` to format current buffer
command! -nargs=0 Format :call CocAction('format')

" Use `:Fold` to fold current buffer
command! -nargs=? Fold :call     CocAction('fold', <f-args>)

" use `:OR` for organize import of current buffer
command! -nargs=0 OR   :call     CocAction('runCommand', 'editor.action.organizeImport')

" Add status line support, for integration with other plugin, checkout `:h coc-status`
set statusline^=%{coc#status()}%{get(b:,'coc_current_function','')}

" Using CocList
" Show all diagnostics
nnoremap <silent> <space>a  :<C-u>CocList diagnostics<cr>
" Manage extensions
nnoremap <silent> <space>e  :<C-u>CocList extensions<cr>
" Show commands
nnoremap <silent> <space>c  :<C-u>CocList commands<cr>
" Find symbol of current document
nnoremap <silent> <space>o  :<C-u>CocList outline<cr>
" Search workspace symbols
nnoremap <silent> <space>s  :<C-u>CocList -I symbols<cr>
" Do default action for next item.
nnoremap <silent> <space>j  :<C-u>CocNext<CR>
" Do default action for previous item.
nnoremap <silent> <space>k  :<C-u>CocPrev<CR>
" Resume latest coc list
nnoremap <silent> <space>p  :<C-u>CocListResume<CR>

" For lightline integration with Coc
function! CocCurrentFunction()
    return get(b:, 'coc_current_function', '')
endfunction

let g:lightline = {
      \ 'colorscheme': 'jellybeans',
      \ 'active': {
      \   'left': [ [ 'mode', 'paste' ],
      \             [ 'cocstatus', 'currentfunction', 'readonly', 'filename', 'modified' ] ]
      \ },
      \ 'component_function': {
      \   'cocstatus': 'coc#status',
      \   'currentfunction': 'CocCurrentFunction'
      \ },
      \ 'separator': { 'left': '', 'right': ''},
      \ 'subseparator': { 'left': '', 'right': ''},
      \ }
