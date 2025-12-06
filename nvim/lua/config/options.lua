-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

local opt = vim.opt

-- turn off relative line numbers
opt.number = true
opt.relativenumber = false

-- remove ro, don't automatically continue comment lines
opt.formatoptions = "jcqlnt" -- jcroqlnt is default
