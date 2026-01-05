return {
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
    version = false,
    build = ":TSUpdate",
    event = { "LazyFile", "VeryLazy" },
    cmd = { "TSUpdate", "TSInstall", "TSLog", "TSUninstall" },
    opts_extend = { "ensure_installed" },
    opts = {
      highlight = { enable = true },
      indent = { enable = true },
      folds = { enable = false },
      ensure_installed = {
        "bash",
        "c",
        "diff",
        "go",
        "gomod",
        "gosum",
        "gowork",
        "html",
        "javascript",
        "jsdoc",
        "json",
        "lua",
        "luadoc",
        "luap",
        "markdown",
        "markdown_inline",
        "printf",
        "python",
        "query",
        "regex",
        "toml",
        "tsx",
        "typescript",
        "vim",
        "vimdoc",
        "xml",
        "yaml",
      },
    },
    config = function(_, opts)
      local ts = require("nvim-treesitter")

      ts.setup(opts)

      local installed_cache = nil
      local query_cache = {}

      local function get_installed(refresh)
        if refresh or installed_cache == nil then
          installed_cache = {}
          query_cache = {}
          for _, lang in ipairs(ts.get_installed("parsers")) do
            installed_cache[lang] = true
          end
        end
        return installed_cache
      end

      local function is_installed(lang)
        return get_installed()[lang] == true
      end

      local function has_query(lang, query)
        local key = lang .. ":" .. query
        if query_cache[key] == nil then
          local ok, q = pcall(vim.treesitter.query.get, lang, query)
          query_cache[key] = ok and q ~= nil
        end
        return query_cache[key]
      end

      local function lang_for_ft(ft)
        return vim.treesitter.language.get_lang(ft)
      end

      local function feature_enabled(feat, lang, query)
        local cfg = opts[feat] or {}
        return cfg.enable ~= false
          and not (
            type(cfg.disable) == "table"
            and vim.tbl_contains(cfg.disable, lang)
          )
          and has_query(lang, query)
      end

      get_installed(true)

      local missing = vim.tbl_filter(function(parser)
        return not is_installed(parser)
      end, opts.ensure_installed or {})

      if #missing > 0 then
        ts.install(missing, { summary = true }):await(function()
          get_installed(true)
        end)
      end

      local group = vim.api.nvim_create_augroup("treesitter_features", {
        clear = true,
      })

      vim.api.nvim_create_autocmd("FileType", {
        group = group,
        callback = function(ev)
          local ft = ev.match
          local lang = lang_for_ft(ft)

          if not lang or not is_installed(lang) then
            return
          end

          -- highlighting
          if feature_enabled("highlight", lang, "highlights") then
            pcall(vim.treesitter.start, ev.buf)
          end

          -- indents
          if feature_enabled("indent", lang, "indents") then
            vim.bo[ev.buf].indentexpr =
              "v:lua.require('nvim-treesitter').indentexpr()"
          end

          -- folds
          if feature_enabled("folds", lang, "folds") then
            vim.api.nvim_set_option_value("foldmethod", "expr", { win = 0 })
            vim.api.nvim_set_option_value(
              "foldexpr",
              "v:lua.vim.treesitter.foldexpr()",
              { win = 0 }
            )
          end
        end,
      })
    end,
  },

  {
    "nvim-treesitter/nvim-treesitter-textobjects",
    branch = "main",
    event = "VeryLazy",
    dependencies = { "nvim-treesitter/nvim-treesitter" },
  },

  -- closing tags for html and jsx
  {
    "windwp/nvim-ts-autotag",
    event = "LazyFile",
    opts = {},
  },
}
