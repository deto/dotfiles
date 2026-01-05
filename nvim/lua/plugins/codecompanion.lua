return {
  {
    "olimorris/codecompanion.nvim",
    opts = {
      strategies = {
        chat = {
          adapter = "copilot",
        },
      },
    },
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
  },
}
