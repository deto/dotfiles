return {
  "jpalardy/vim-slime",
  config = function()
    -- Plugin options (converted from Vimscript)
    vim.g.slime_target = "tmux"
    vim.g.slime_bracketed_paste = 1
    vim.g.slime_preserve_curpos = 1
    vim.g.slime_paste_file = vim.fn.tempname()
    vim.g.slime_no_mappings = 1

    -- Optional: Lua version of SendCell function
    function _G.SendCell()
      local ft = vim.bo.filetype
      local pattern

      if ft == "rmd" or ft == "markdown" then
        pattern = "^```"
      else
        -- default: Jupyter style (e.g. Python with # %%)
        pattern = "^#..%%"
      end

      local start_line = vim.fn.search(pattern, "bnW")
      if start_line == 0 then
        start_line = 1
      else
        start_line = start_line + 1
      end

      local stop_line = vim.fn.search(pattern, "nW")
      if stop_line ~= 0 then
        stop_line = stop_line - 1
      else
        stop_line = vim.fn.line("$")
      end

      vim.fn["slime#send_range"](start_line, stop_line)
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
