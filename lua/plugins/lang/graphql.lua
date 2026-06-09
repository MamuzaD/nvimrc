return {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      ensure_installed = { "graphql" },
    },
  },

  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        graphql = {
          filetypes = {
            "graphql",
            "javascript",
            "javascriptreact",
            "typescript",
            "typescriptreact",
          },
        },
      },
    },
  },
}
