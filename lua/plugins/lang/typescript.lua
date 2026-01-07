return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      -- make sure mason installs the server
      servers = {
        vtsls = {
          root = { "tsconfig.json", "package.json", "jsconfig.json" },
          filetypes = {
            "javascript",
            "javascriptreact",
            "javascript.jsx",
            "typescript",
            "typescriptreact",
            "typescript.tsx",
          },
          settings = {
            complete_function_calls = true,
            vtsls = {
              enableMoveToFileCodeAction = true,
              autoUseWorkspaceTsdk = true,
              experimental = {
                maxInlayHintLength = 30,
                completion = {
                  enableServerSideFuzzyMatch = true,
                },
              },
            },
            typescript = {
              updateImportsOnFileMove = { enabled = "always" },
              suggest = {
                completeFunctionCalls = true,
              },
              inlayHints = {
                enumMemberValues = { enabled = true },
                functionLikeReturnTypes = { enabled = true },
                parameterNames = { enabled = "literals" },
                parameterTypes = { enabled = true },
                propertyDeclarationTypes = { enabled = true },
                variableTypes = { enabled = false },
              },
            },
          },
          keys = {
            {
              "gD",
              function()
                local win = vim.api.nvim_get_current_win()
                local params = vim.lsp.util.make_position_params(win, "utf-16")
                util.lang.execute_command(
                  "typescript.goToSourceDefinition",
                  { params.textDocument.uri, params.position },
                  true
                )
              end,
              desc = "Goto Source Definition",
            },
            {
              "gR",
              function()
                util.lang.execute_command("typescript.findAllFileReferences", { vim.uri_from_bufnr(0) }, true)
              end,
              desc = "File References",
            },
            {
              "<leader>co",
              util.lang.source_action("source.organizeImports"),
              desc = "Organize Imports",
            },
            {
              "<leader>cM",
              util.lang.source_action("source.addMissingImports.ts"),
              desc = "Add missing imports",
            },
            {
              "<leader>cu",
              util.lang.source_action("source.removeUnused.ts"),
              desc = "Remove unused imports",
            },
            {
              "<leader>cD",
              util.lang.source_action("source.fixAll.ts"),
              desc = "Fix all diagnostics",
            },
            {
              "<leader>cV",
              function()
                util.lang.execute_command("typescript.selectTypeScriptVersion")
              end,
              desc = "Select TS workspace version",
            },
          },
        },
      },
      setup = {
        vtsls = function(_, opts)
          -- copy typescript settings to javascript
          opts.settings.javascript =
            vim.tbl_deep_extend("force", {}, opts.settings.typescript, opts.settings.javascript or {})
        end,
      },
    },
  },

  -- filetype icons
  {
    "nvim-mini/mini.icons",
    opts = {
      file = {
        [".eslintrc.js"] = { glyph = "󰱺", hl = "MiniIconsYellow" },
        [".node-version"] = { glyph = "", hl = "MiniIconsGreen" },
        [".prettierrc"] = { glyph = "", hl = "MiniIconsPurple" },
        [".yarnrc.yml"] = { glyph = "", hl = "MiniIconsBlue" },
        ["eslint.config.js"] = { glyph = "󰱺", hl = "MiniIconsYellow" },
        ["package.json"] = { glyph = "", hl = "MiniIconsGreen" },
        ["tsconfig.json"] = { glyph = "", hl = "MiniIconsAzure" },
        ["tsconfig.build.json"] = { glyph = "", hl = "MiniIconsAzure" },
        ["yarn.lock"] = { glyph = "", hl = "MiniIconsBlue" },
      },
    },
  },
}
