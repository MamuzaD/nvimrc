return {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = { ensure_installed = { "ninja", "rst" } },
  },
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        ruff = {
          cmd_env = { RUFF_TRACE = "messages" },
          init_options = {
            settings = {
              logLevel = "error",
            },
          },
          keys = {
            {
              "<leader>co",
              util.lang.source_action("source.organizeImports"),
              desc = "Organize Imports",
            },
          },
        },
        basedpyright = {
          settings = {
            basedpyright = {
              analysis = {
                diagnosticSeverityOverrides = {
                  reportAny = "none",
                  reportMissingTypeStubs = "none",
                  reportImplicitRelativeImport = "none",
                  reportUnknownVariableType = "none",
                  reportExplicitAny = "none",
                  reportUnknownMemberType = "none",
                  reportUnknownParameterType = "none",
                  reportMissingParameterType = "none",
                  reportMissingTypeArgument = "none",
                  reportInvalidCast = "none",
                  reportUnusedCallResult = "none",
                  reportImportCycles = "none",
                  reportUnannotatedClassAttribute = "none",
                  reportUnknownLambdaType = "none",
                  reportUnknownArgumentType = "none",
                },
              },
            },
          },
        },
      },
      setup = {
        ruff = function()
          Snacks.util.lsp.on({ name = "ruff" }, function(_, client)
            -- Disable hover in favor of Pyright
            client.server_capabilities.hoverProvider = false
          end)
        end,
      },
    },
  },
  {
    "linux-cultist/venv-selector.nvim",
    cmd = "VenvSelect",
    opts = {
      options = {
        notify_user_on_venv_activation = true,
        override_notify = false,
      },
    },
    --  Call config for Python files and load the cached venv automatically
    ft = "python",
    keys = { { "<leader>cv", "<cmd>:VenvSelect<cr>", desc = "Select VirtualEnv", ft = "python" } },
  },
}
