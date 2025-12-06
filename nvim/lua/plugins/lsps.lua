return {
  -- The package that provides the lspconfig setup function
  "neovim/nvim-lspconfig",
  opts = {
    -- Extend the settings for r_language_server
    servers = {
      r_language_server = {
        -- This function is used to find the project root
        root_dir = require("lspconfig.util").root_pattern(
          ".Rprofile", -- <-- Adding this one
          ".Rproj", -- The default RStudio marker
          ".git" -- The common Git marker
        ),
      },
    },
  },
}
