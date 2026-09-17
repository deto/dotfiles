return {
  "jpalardy/vim-slime",
  init = function()
    vim.g.slime_no_mappings = 1
  end,
  config = function()
    local tmux_transport = require("config.slime_tmux")

    -- Plugin options (converted from Vimscript)
    vim.g.slime_target = "tmux"
    vim.g.slime_bracketed_paste = 1
    vim.g.slime_preserve_curpos = 1
    vim.g.slime_paste_file = vim.fn.tempname()

    -- vim-slime uses tmux's latest unnamed paste buffer. Its chunk loop also
    -- tries to paste an empty chunk when the text length is a multiple of 1000,
    -- causing tmux to paste unrelated clipboard history. Use a private named
    -- buffer and never attempt an empty chunk.
    _G.SlimeTmuxSend = tmux_transport.send
    vim.cmd([[
      function! SlimeOverrideSend(config, text) abort
        call v:lua.SlimeTmuxSend(a:config, a:text)
      endfunction
    ]])

    -- Optional: Lua version of SendCell function
    function _G.SendCell()
      local ft = vim.bo.filetype
      local pattern

      if ft == "rmd" or ft == "markdown" then
        pattern = "^```"
      else
        -- default: Jupyter style (e.g. Python with # %%)
        pattern = "^# %%"
      end

      local start_line = vim.fn.search(pattern, "bcnW")
      if start_line == 0 then
        start_line = 1
      else
        start_line = start_line + 1
      end

      local next_cell_line = vim.fn.search(pattern, "nW")
      local stop_line
      if next_cell_line ~= 0 then
        stop_line = next_cell_line - 1
      else
        stop_line = vim.fn.line("$")
      end

      vim.fn["slime#send_range"](start_line, stop_line)

      if next_cell_line ~= 0 then
        vim.api.nvim_win_set_cursor(0, { next_cell_line, 0 })
      end
    end
  end,
  keys = {
    { "<C-c><C-c>", "<Plug>SlimeRegionSend", mode = "x", desc = "Send selection to tmux" },
    {
      "<C-c><C-c>",
      function()
        _G.SendCell()
      end,
      mode = "n",
      desc = "Send cell to tmux",
    },
    { "<C-c>v", "<Plug>SlimeConfig", mode = "n", desc = "Slime config" },
  },
}
