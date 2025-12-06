return {
  -- Target the nvim-cmp plugin
  "hrsh7th/nvim-cmp",

  -- Use the opts function to override default settings
  opts = function(_, opts)
    -- Ensure the completion table exists, then set autocomplete to false
    opts.completion = opts.completion or {}
    opts.completion.autocomplete = false

    -- Ensure the manual trigger key is mapped if you rely on it
    -- (e.g., <C-Space> or <Tab> from your previous configuration)
    local cmp = require("cmp")

    -- Here this is the LazyVim default but I've overridden the tab mapping
    opts.mapping = cmp.mapping.preset.insert({
      ["<C-b>"] = cmp.mapping.scroll_docs(-4),
      ["<C-f>"] = cmp.mapping.scroll_docs(4),
      ["<C-n>"] = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Insert }),
      ["<C-p>"] = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Insert }),
      ["<C-Space>"] = cmp.mapping.complete(),
      ["<CR>"] = LazyVim.cmp.confirm({ select = true }),
      ["<C-y>"] = LazyVim.cmp.confirm({ select = true }),
      ["<S-CR>"] = LazyVim.cmp.confirm({ behavior = cmp.ConfirmBehavior.Replace }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
      ["<C-CR>"] = function(fallback)
        cmp.abort()
        fallback()
      end,
      ["<tab>"] = function(fallback)
        return LazyVim.cmp.map({ "snippet_forward", "ai_nes", "ai_accept" }, fallback)()
      end,
    })

    return opts
  end,
}
