return {
  {
    "olimorris/codecompanion.nvim",
    opts = {
      strategies = {
        chat = {
          adapter = "copilot",
          model = "GPT-5.4",
        },
      },
    },
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
    keys = {
      { "<leader>cc", "<cmd>CodeCompanionChat Toggle<cr>", desc = "CodeCompanion Chat Toggle", mode = { "n", "v" } },
    },
  },
}
