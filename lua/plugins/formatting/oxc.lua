-- oxc toolchain: oxfmt (formatter) + oxlint (linter).
--
-- Gated behind `vim.g.use_oxc` so it swaps in for prettier on JS/TS.
-- Prettier still handles css/html/markdown/yaml/graphql (see prettier.lua).
--
-- oxlint runs as an LSP (code actions, fix all, live diagnostics) and only
-- attaches when an oxlint config is found. oxfmt runs through conform.
--
-- Set `vim.g.oxc_needs_config = true` to only run oxfmt when an oxc config file
-- is present (mirrors `vim.g.prettier_needs_config`).
return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        oxlint = {
          root_dir = function(bufnr, on_dir)
            if not require("daniel.util.oxc").enabled() then
              return
            end
            -- prefer the top-level oxlint config if it exists (monorepo support)
            local git = vim.fs.root(bufnr, ".git")
            local markers = { ".oxlintrc.json", ".oxlintrc.jsonc", "oxlint.config.ts" }
            local root = git and vim.fs.root(git, markers) or vim.fs.root(bufnr, markers)
            if root then
              on_dir(root)
            end
          end,
          settings = {
            fixKind = "all",
          },
        },
        -- formatting goes through conform, not the oxfmt lsp
        oxfmt = { enabled = false },
      },
    },
  },

  -- Make sure oxfmt is available (mason provides a global fallback;
  -- project-local node_modules/.bin/oxfmt is preferred automatically).
  {
    "mason-org/mason.nvim",
    opts = { ensure_installed = { "oxfmt" } },
  },

  -- Formatting: oxfmt for JS/TS/JSON/Vue, when `vim.g.use_oxc` is on.
  {
    "stevearc/conform.nvim",
    optional = true,
    opts = function(_, opts)
      local oxc = require("daniel.util.oxc")
      opts.formatters_by_ft = opts.formatters_by_ft or {}
      for _, ft in ipairs(oxc.fmt_filetypes) do
        opts.formatters_by_ft[ft] = opts.formatters_by_ft[ft] or {}
        table.insert(opts.formatters_by_ft[ft], "oxfmt")
      end

      opts.formatters = opts.formatters or {}
      opts.formatters.oxfmt = {
        condition = function(_, ctx)
          return oxc.formats(ctx.filename, vim.bo[ctx.buf].filetype)
        end,
      }
    end,
  },
}
