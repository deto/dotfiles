return {
  {
    "olimorris/codecompanion.nvim",
    opts = {
      strategies = {
        chat = {
          adapter = "codex",
        },
      },
      adapters = {
        acp = {
          codex = function()
            return require("codecompanion.adapters").extend("codex", {
              defaults = {
                auth_method = "chatgpt",
              },
            })
          end,
        },
      },
    },
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
  },
}
