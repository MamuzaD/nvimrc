-- oxc toolchain: oxfmt (formatter) + oxlint (linter).
--
-- Gated behind `vim.g.use_oxc` so it swaps in for prettier/eslint on JS/TS.
-- Prettier still handles css/html/markdown/yaml/graphql/vue (see prettier.lua).
--
-- Set `vim.g.oxc_needs_config = true` to only run oxfmt when an oxc config file
-- is present (mirrors `vim.g.prettier_needs_config`).
return {
  -- Make sure the binaries are available (mason provides a global fallback;
  -- project-local node_modules/.bin/oxfmt|oxlint are preferred automatically).
  {
    "mason-org/mason.nvim",
    opts = { ensure_installed = { "oxlint", "oxfmt" } },
  },

  -- Formatting: oxfmt for JS/TS/JSON, only when the toggle is on.
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

  -- Linting: oxlint for JS/TS, only when the toggle is on.
  {
    "mfussenegger/nvim-lint",
    optional = true,
    opts = function(_, opts)
      local oxc = require("daniel.util.oxc")
      opts.linters_by_ft = opts.linters_by_ft or {}
      for _, ft in ipairs(oxc.lint_filetypes) do
        opts.linters_by_ft[ft] = opts.linters_by_ft[ft] or {}
        table.insert(opts.linters_by_ft[ft], "oxlint")
      end

      opts.linters = opts.linters or {}
      opts.linters.oxlint = {
        condition = function()
          return oxc.enabled()
        end,
      }
    end,
  },
}
