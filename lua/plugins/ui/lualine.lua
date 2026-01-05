local function pretty_path()
  local path = vim.fn.expand("%:p")
  local cwd = vim.fn.getcwd()
  if path:find(cwd, 1, true) == 1 then
    path = path:sub(#cwd + 2)
  end
  return path
end

local icons = {
  diagnostics = {
    Error = "󰅚 ",
    Warn = "󰀪 ",
    Info = "󰋼 ",
    Hint = "󰌶 ",
  },
  git = {
    added = "󰐕 ",
    modified = "󰏫 ",
    removed = "󰍴 ",
  },
}

return {
  -- Displays a fancy status line with git status,
  -- LSP diagnostics, filetype information, and more.
  "nvim-lualine/lualine.nvim",
  event = "VeryLazy",
  init = function()
    vim.g.lualine_laststatus = vim.o.laststatus
    -- if vim.fn.argc(-1) > 0 then
    --   -- set an empty statusline till lualine loads
    --   vim.o.statusline = " "
    -- else
    --   -- hide the statusline on the starter page
    --   vim.o.laststatus = 0
    -- end
  end,
  opts = function()
    -- PERF: we don't need this lualine require madness 🤷
    local lualine_require = require("lualine_require")
    lualine_require.require = require

    vim.o.laststatus = vim.g.lualine_laststatus

    local opts = {
      options = {
        theme = "auto",
        globalstatus = vim.o.laststatus == 3,
        disabled_filetypes = { statusline = { "dashboard", "alpha", "ministarter", "snacks_dashboard" } },
        section_separators = { left = "", right = "" }, -- straight line: no arrows
        component_separators = { left = "", right = "" }, -- straight line: no tick marks
      },
      sections = {
        lualine_a = { { "mode", padding = { left = 2, right = 3 } } },
        lualine_b = { { "branch", padding = { left = 1, right = 1 } } },

        lualine_c = {
          {
            "diagnostics",
            symbols = {
              error = icons.diagnostics.Error,
              warn = icons.diagnostics.Warn,
              info = icons.diagnostics.Info,
              hint = icons.diagnostics.Hint,
            },
          },
          { "filetype", icon_only = true, separator = "", padding = { left = 1, right = 0 } },
          pretty_path,
        },
        lualine_x = {
          -- stylua: ignore
          {
            function() return require("noice").api.status.command.get() end,
            cond = function() return package.loaded["noice"] and require("noice").api.status.command.has() end,
          },
          -- stylua: ignore
          {
            function() return require("noice").api.status.mode.get() end,
            cond = function() return package.loaded["noice"] and require("noice").api.status.mode.has() end,
          },
          -- stylua: ignore
          {
            function() return "  " .. require("dap").status() end,
            cond = function() return package.loaded["dap"] and require("dap").status() ~= "" end,
          },
          -- stylua: ignore
          {
            require("lazy.status").updates,
            cond = require("lazy.status").has_updates,
          },
          {
            "diff",
            symbols = {
              added = icons.git.added,
              modified = icons.git.modified,
              removed = icons.git.removed,
            },
            source = function()
              local gitsigns = vim.b.gitsigns_status_dict
              if gitsigns then
                return {
                  added = gitsigns.added,
                  modified = gitsigns.changed,
                  removed = gitsigns.removed,
                }
              end
            end,
            color = { bg = "#333333" },
          },
        },
        lualine_y = {
          { "location", padding = { left = 1, right = 0 } },
          { "progress", separator = " ", padding = { left = 1, right = 1 } },
        },
        lualine_z = {
          {
            function()
              return os.date("%A")
            end,
            padding = { left = 2, right = 2 },
          },
        },
      },
      extensions = { "neo-tree", "lazy", "fzf" },
    }

    -- do not add trouble symbols if aerial is enabled
    -- And allow it to be overriden for some buffer types (see autocmds)
    local has_trouble = pcall(require, "trouble")
    if vim.g.trouble_lualine and has_trouble then
      local trouble = require("trouble")
      local symbols = trouble.statusline({
        mode = "symbols",
        groups = {},
        title = false,
        filter = { range = true },
        format = "{kind_icon}{symbol.name:Normal}",
        hl_group = "lualine_c_normal",
      })
      table.insert(opts.sections.lualine_c, {
        symbols and symbols.get,
        cond = function()
          return vim.b.trouble_lualine ~= false and symbols.has()
        end,
      })
    end

    return opts
  end,
}
