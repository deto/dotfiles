"Change leader key to space
let mapleader = "\<Space>"


call plug#begin()

"Send text to Tmux panes
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

"StatusLine Plugin
Plug 'itchyny/lightline.vim'
let g:lightline = {
            \ 'colorscheme': 'jellybeans',
            \ 'separator': { 'left': '', 'right': ''},
            \ 'subseparator': { 'left': '', 'right': ''},
            \ 'enable': { 'statusline': '1', 'tabline': '0'},
            \}


" Python Indenting
Plug 'hynek/vim-python-pep8-indent'

" Python text-objects
Plug 'michaeljsmith/vim-indent-object'

" Good searching of files with Ack/Ag
Plug 'mileszs/ack.vim'
let g:ackprg = 'ag --vimgrep'

" Fuzzy Finder
Plug 'nvim-lua/plenary.nvim'
Plug 'nvim-telescope/telescope.nvim'
Plug 'nvim-telescope/telescope-fzf-native.nvim', { 'do': 'make', 'branch': 'main'}
" Needs rg (ripgrep) and recommends fd (sharkdp/fd)
" Needs fzf
"
" Telescope key bindings
nnoremap <leader>ff <cmd>Telescope find_files<cr>
nnoremap <leader>fg <cmd>Telescope git_files<cr>
nnoremap <leader>fb <cmd>Telescope buffers<cr>
nnoremap <leader>fh <cmd>Telescope help_tags<cr>


" New stuff for language servers

Plug 'neovim/nvim-lspconfig'

Plug 'hrsh7th/cmp-nvim-lsp'
Plug 'hrsh7th/cmp-buffer'
Plug 'hrsh7th/cmp-path'
Plug 'hrsh7th/cmp-cmdline'
Plug 'hrsh7th/nvim-cmp'

" For vsnip users -- needed for nvim-cmp
Plug 'hrsh7th/cmp-vsnip'
Plug 'hrsh7th/vim-vsnip'

" Tresitter
Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}

Plug 'christoomey/vim-tmux-navigator'

" Bufferline!

Plug 'kyazdani42/nvim-web-devicons' " (for coloured icons)
Plug 'akinsho/bufferline.nvim', { 'tag': 'v2.*' }

" New Tree view
Plug 'kyazdani42/nvim-tree.lua'
" Plug 'kyazdani42/nvim-web-devicons' " (for coloured icons)

call plug#end()

set background=dark
colorscheme vim-monokai-tasty

set mouse=a

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


" New stuff for language servers
" Good reference here: https://vonheikemen.github.io/devlog/tools/setup-nvim-lspconfig-plus-nvim-cmp/
lua << EOF


    -- This is recommended by nvim-tree to disable netrw
    vim.g.loaded = 1
    vim.g.loaded_netrwPlugin = 1

    local lsp_defaults = {
      flags = {
        debounce_text_changes = 150,
      },
      capabilities = require('cmp_nvim_lsp').update_capabilities(
        vim.lsp.protocol.make_client_capabilities()
      ),
      on_attach = function(client, bufnr)
        vim.api.nvim_exec_autocmds('User', {pattern = 'LspAttached'})

        if client.resolved_capabilities.document_formatting == true then
            -- vim.api.nvim_buf_set_option(bufnr, "formatexpr", "v:lua.vim.lsp.formatexpr()")
            -- Add this <leader> bound mapping so formatting the entire document is easier.
            vim.keymap.set("n", "<leader>gq", "<cmd>lua vim.lsp.buf.formatting()<CR>", {buffer = true})
            vim.keymap.set("v", "gq", "<ESC><cmd>lua vim.lsp.buf.range_formatting()<CR>", {buffer = true})
        end
      end
    }

    vim.lsp.set_log_level("debug")

    local lspconfig = require('lspconfig')

    -- This merges our lsp_defaults with the default lsp configs
    lspconfig.util.default_config = vim.tbl_deep_extend(
      'force',
      lspconfig.util.default_config,
      lsp_defaults
    )

    -- options are here: https://github.com/python-lsp/python-lsp-server/blob/develop/CONFIGURATION.md
    -- Can maybe use both pylsp and pyright?  https://www.reddit.com/r/neovim/comments/sazbw6/python_language_servers/
    lspconfig.pylsp.setup{
        settings = {
            pylsp = {
                plugins = {
                    flake8 = {
                        enabled = true,
                    },
                    pycodestyle = {
                        enabled = false,
                    },
                    pyflakes = {
                        enabled = false,
                    },
                }
            }
        }
    }  -- requires `pip install python-language-server`
    lspconfig.r_language_server.setup{} -- requires `install.packages('languageserver')`

    vim.opt.signcolumn = "yes" -- reserves space along left side for diag signs

    -- Setup Keybindings, uses the autocommand group from lsp_defaults earlier
    vim.api.nvim_create_autocmd('User', {
      pattern = 'LspAttached',
      desc = 'LSP actions',
      callback = function()
        local bufmap = function(mode, lhs, rhs)
          local opts = {buffer = true}
          vim.keymap.set(mode, lhs, rhs, opts)
        end

        -- Displays hover information about the symbol under the cursor
        bufmap('n', 'K', '<cmd>lua vim.lsp.buf.hover()<cr>')

        -- Jump to the definition
        bufmap('n', 'gd', '<cmd>lua vim.lsp.buf.definition()<cr>')

        -- Jump to declaration
        bufmap('n', 'gD', '<cmd>lua vim.lsp.buf.declaration()<cr>')

        -- Lists all the implementations for the symbol under the cursor
        bufmap('n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<cr>')

        -- Jumps to the definition of the type symbol
        bufmap('n', 'go', '<cmd>lua vim.lsp.buf.type_definition()<cr>')

        -- Lists all the references 
        bufmap('n', 'gr', '<cmd>lua vim.lsp.buf.references()<cr>')

        -- Displays a function's signature information
        bufmap('n', 'gk', '<cmd>lua vim.lsp.buf.signature_help()<cr>')

        -- Renames all references to the symbol under the cursor
        bufmap('n', '<F2>', '<cmd>lua vim.lsp.buf.rename()<cr>')

        -- Selects a code action available at the current cursor position
        bufmap('n', '<F4>', '<cmd>lua vim.lsp.buf.code_action()<cr>')
        bufmap('x', '<F4>', '<cmd>lua vim.lsp.buf.range_code_action()<cr>')

        -- Show diagnostics in a floating window
        bufmap('n', 'gl', '<cmd>lua vim.diagnostic.open_float()<cr>')

        -- Move to the previous diagnostic
        bufmap('n', '[d', '<cmd>lua vim.diagnostic.goto_prev()<cr>')

        -- Move to the next diagnostic
        bufmap('n', ']d', '<cmd>lua vim.diagnostic.goto_next()<cr>')

        -- Other options, potentially useful?
        -- See `:help vim.lsp.*` for documentation on any of the below functions
        -- buf_set_keymap('n', '<space>wa', '<cmd>lua vim.lsp.buf.add_workspace_folder()<CR>', opts)
        -- buf_set_keymap('n', '<space>wr', '<cmd>lua vim.lsp.buf.remove_workspace_folder()<CR>', opts)
        -- buf_set_keymap('n', '<space>wl', '<cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<CR>', opts)
        -- buf_set_keymap('n', '<space>q', '<cmd>lua vim.diagnostic.setloclist()<CR>', opts)
        -- buf_set_keymap('n', '<space>f', '<cmd>lua vim.lsp.buf.formatting()<CR>', opts)

      end
    })

    -- Setup nvim-cmp.

    vim.opt.completeopt = {'menu', 'menuone', 'noselect'}

    local cmp = require('cmp')

    local select_opts = {behavior = cmp.SelectBehavior.Select}

    cmp.setup({
        snippet = {
          -- REQUIRED - you must specify a snippet engine
          expand = function(args)
            vim.fn["vsnip#anonymous"](args.body) -- For `vsnip` users.
            -- require('luasnip').lsp_expand(args.body) -- For `luasnip` users.
            -- vim.fn["UltiSnips#Anon"](args.body) -- For `ultisnips` users.
            -- require'snippy'.expand_snippet(args.body) -- For `snippy` users.
          end,
        },
        sources = {
          { name = 'path' },
          { name = 'nvim_lsp', keyword_length = 3 },
          { name = 'buffer', keyword_length = 3 },
          { name = 'vsnip', keyword_length = 3 }, -- For vsnip users.
          -- { name = 'luasnip' }, -- For luasnip users.
          -- { name = 'ultisnips' }, -- For ultisnips users.
          -- { name = 'snippy' }, -- For snippy users.
        },
        window = {
            -- Create bordered documentation window
            documentation = cmp.config.window.bordered()
        },
        formatting = {
            fields = {'menu', 'abbr', 'kind'}
            -- Also, see the blog post at the top of this section for
            -- how to extend this section and assign icons based on
            -- completetion source
        },
        mapping = {
            ['<C-b>'] = cmp.mapping(cmp.mapping.scroll_docs(-4), { 'i', 'c' }),
            ['<C-f>'] = cmp.mapping(cmp.mapping.scroll_docs(4), { 'i', 'c' }),
            ['<C-Space>'] = cmp.mapping(cmp.mapping.complete(), { 'i', 'c' }),
            ['<C-y>'] = cmp.config.disable, -- Specify `cmp.config.disable` if you want to remove the default `<C-y>` mapping.
            ['<C-e>'] = cmp.mapping({
              i = cmp.mapping.abort(),
              c = cmp.mapping.close(),
            }),
            -- Accept currently selected item. If none selected, `select` first item.
            -- Set `select` to `false` to only confirm explicitly selected items.
            ['<CR>'] = cmp.mapping.confirm({ select = true }),

            -- If the completion menu is visible, move to the next item. If the line is
            -- "empty", insert a Tab character. If the cursor is inside a word,
            -- trigger the completion menu.
            ['<Tab>'] = cmp.mapping(function(fallback)
                local col = vim.fn.col('.') - 1

                if cmp.visible() then
                    cmp.select_next_item(select_opts)
                elseif col == 0 or vim.fn.getline('.'):sub(col, col):match('%s') then
                    fallback()
                else
                    cmp.complete()
                end
            end, {'i', 's'}),
        },
    })

    local sign = function(opts)
      vim.fn.sign_define(opts.name, {
        texthl = opts.name,
        text = opts.text,
        numhl = ''
      })
    end

    sign({name = 'DiagnosticSignError', text = '✘'})
    sign({name = 'DiagnosticSignWarn', text = '▲'})
    sign({name = 'DiagnosticSignHint', text = '⚑'})
    sign({name = 'DiagnosticSignInfo', text = ''})


    -- Config for nvim-treesitter
    -- Just enable highlighting for now
    require'nvim-treesitter.configs'.setup {
        ensure_installed = {"python", "r"}, -- one of "all", "maintained" (parsers with maintainers), or a list of languages
        sync_install = false, -- install languages synchronously (only applied to `ensure_installed`)
        ignore_install = { "javascript" }, -- List of parsers to ignore installing
        highlight = {
            enable = true,                            -- false will disable the whole extension
            disable = { "c", "rust" },    -- list of language that will be disabled
            -- Setting this to true will run `:h syntax` and tree-sitter at the same time.
            -- Set this to `true` if you depend on 'syntax' being enabled (like for indentation).
            -- Using this option may slow down your editor, and you may see some duplicate highlights.
            -- Instead of true it can also be a list of languages
            additional_vim_regex_highlighting = false,
        },
    }

    require('telescope').setup {
        extensions = {
            fzf = {
                fuzzy = true,                                        -- false will only do exact matching
                override_generic_sorter = true,    -- override the generic sorter
                override_file_sorter = true,         -- override the file sorter
                case_mode = "smart_case",                -- or "ignore_case" or "respect_case"
                                                                                 -- the default case_mode is "smart_case"
            }
        }
    }
    -- To get fzf loaded and working with telescope, you need to call
    -- load_extension, somewhere after setup function:
    require('telescope').load_extension('fzf')

    -- Init for bufferline
    vim.opt.termguicolors = true
    require("bufferline").setup{
        options = {
            show_close_icon = false,
            separator_style = "slant",
            offsets = {
                {
                filetype = "NvimTree",
                text = "File Explorer",
                text_align = "center",
                separator = false
                },
            }
        }
    }

    -- Config for tree view

    require("nvim-tree").setup()
    vim.api.nvim_set_keymap('n', '<leader>t', ':NvimTreeToggle<CR>', { noremap = true, silent = true })

EOF
