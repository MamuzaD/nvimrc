return {
  {
    "supermaven-inc/supermaven-nvim",
    enabled = vim.g.ai_cmp == true,
    event = "InsertEnter",
    cmd = {
      "SupermavenUseFree",
      "SupermavenUsePro",
    },
    opts = {
      keymaps = {
        accept_suggestion = nil, -- handled by blink.cmp
      },
      disable_inline_completion = vim.g.ai_cmp,
      ignore_filetypes = { "bigfile", "snacks_input", "snacks_notif" },
    },
  },
  {
    "supermaven-inc/supermaven-nvim",
    enabled = vim.g.ai_cmp == true,
    opts = function()
      require("supermaven-nvim.completion_preview").suggestion_group = "SupermavenSuggestion"
    end,
  },
  vim.g.ai_cmp and {
    "saghen/blink.cmp",
    optional = true,
    dependencies = { "supermaven-inc/supermaven-nvim", "saghen/blink.compat" },
    opts = {
      sources = {
        compat = { "supermaven" },
        providers = {
          supermaven = {
            kind = "Supermaven",
            score_offset = 100,
            async = true,
          },
        },
      },
    },
  } or nil,
  {
    "folke/noice.nvim",
    optional = true,
    opts = function(_, opts)
      vim.list_extend(opts.routes, {
        {
          filter = {
            event = "msg_show",
            any = {
              { find = "Starting Supermaven" },
              { find = "Supermaven Free Tier" },
            },
          },
          skip = true,
        },
      })
    end,
  },
  {
    "nvim-lualine/lualine.nvim",
    optional = true,
    opts = function(_, opts)
      local icon = " "
      local started = false
      local supermaven_component = {
        function()
          return icon
        end,
        cond = function()
          local api = require("supermaven-nvim.api")
          local running = api.is_running()
          if running then
            started = true
          end
          return running or started
        end,
        color = function()
          local api = require("supermaven-nvim.api")
          if api.is_running() then
            return { fg = "#00aa00", bg = "#333333" }
          else
            return { fg = Snacks.util.color("DiagnosticError"), bg = "#333333" } -- error = red
          end
        end,
      }
      table.insert(opts.sections.lualine_x, 6, supermaven_component)
    end,
  },
}
