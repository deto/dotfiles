-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

local map = vim.keymap.set

-- insert-mode jk to Escape
map("i", "jk", "<Esc>", { noremap = true })

-- H / L to start / end of line
vim.keymap.del("n", "<S-h>")
vim.keymap.del("n", "<S-l>")
map({ "n", "v" }, "<S-h>", "^", { noremap = true })
map({ "n", "v" }, "<S-l>", "$", { noremap = true })

-- Buffer switching
-- map("n", "<C-N>", ":bn<CR>", { silent = true, noremap = true })
-- map("n", "<C-P>", ":bp<CR>", { silent = true, noremap = true })
