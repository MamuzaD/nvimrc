return {
  {
    "saghen/blink.cmp",
    version = "*",
    opts_extend = {
      "sources.default",
    },
    dependencies = {
      "rafamadriz/friendly-snippets",
    },
    event = { "InsertEnter", "CmdlineEnter" },
    opts = {
      snippets = { preset = "default" },
      appearance = { nerd_font_variant = "mono" },
      completion = {
        accept = {
          -- experimental auto-brackets support
          auto_brackets = {
            enabled = true,
          },
        },
        menu = {
          draw = {
            treesitter = { "lsp" },
          },
        },
        documentation = {
          auto_show = true,
          auto_show_delay_ms = 200,
        },
        ghost_text = { enabled = true },
      },

      sources = {
        -- adding any nvim-cmp sources here will enable them
        -- with blink.compat
        -- compat = {},
        default = { "lsp", "path", "snippets", "buffer" },
      },

      cmdline = {
        enabled = true,
        keymap = {
          preset = "cmdline",
          ["<Right>"] = false,
          ["<Left>"] = false,
        },
        completion = {
          list = { selection = { preselect = false } },
          menu = {
            auto_show = function()
              return vim.fn.getcmdtype() == ":"
            end,
          },
          ghost_text = { enabled = true },
        },
      },

      keymap = {
        preset = "enter",
        ["<C-y>"] = { "select_and_accept" },
      },
    },
    config = function(_, opts)
      -- Tab to go forward
      if not opts.keymap["<Tab>"] then
        opts.keymap["<Tab>"] = { "snippet_forward", "select_and_accept", "fallback" }
      end

      -- Shift+Tab to go backwards
      if not opts.keymap["<S-Tab>"] then
        opts.keymap["<S-Tab>"] = { "snippet_backward", "select_prev", "fallback" }
      end

      -- Ctrl+j/k for completion navigation
      opts.keymap["<C-j>"] = { "select_next", "fallback" }
      opts.keymap["<C-k>"] = { "select_prev", "fallback" }

      require("blink.cmp").setup(opts)
    end,
  },

  -- add icons
  {
    "saghen/blink.cmp",
    opts = function(_, opts)
      opts.appearance = opts.appearance or {}
      opts.appearance.kind_icons =
        vim.tbl_extend("force", opts.appearance.kind_icons or {}, vim.g.blink_kind_icons or {})
    end,
  },

  -- lazydev
  {
    "saghen/blink.cmp",
    opts = {
      sources = {
        per_filetype = {
          lua = { inherit_defaults = true, "lazydev" },
        },
        providers = {
          lazydev = {
            name = "LazyDev",
            module = "lazydev.integrations.blink",
            score_offset = 100, -- show at a higher priority than lsp
          },
        },
      },
    },
  },
}
