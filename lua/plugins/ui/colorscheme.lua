local colorscheme = "tokyonight"

function ColorMyPencils(color)
  color = color or colorscheme
  vim.cmd.colorscheme(color)
  vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
  vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" })
end

return {
  {
    "folke/tokyonight.nvim",
    -- name = "tokyonight",
    priority = 1000,
    opts = {
      transparent = true,
      styles = { sidebars = "transparent", floats = "transparent" },
    },
    lazy = colorscheme ~= "tokyonight",
    config = function(_, opts)
      require("tokyonight").setup(opts)
      if colorscheme == "tokyonight" then
        ColorMyPencils()
      end
    end,
  },
  -- {
  --   "erikbackman/brightburn.vim",
  --   priority = 1000,
  --   opts = {},
  --   lazy = colorscheme ~= "brightburn",
  --   config = function()
  --     if colorscheme == "brightburn" then
  --       ColorMyPencils()
  --     end
  --   end,
  -- },
  -- {
  --   "ellisonleao/gruvbox.nvim",
  --   -- name = "gruvbox",
  --   priority = 1000,
  --   opts = {},
  --   lazy = colorscheme ~= "gruvbox",
  --   config = function()
  --     if colorscheme == "gruvbox" then
  --       ColorMyPencils()
  --     end
  --   end,
  -- },
  -- {
  --   "catppuccin/nvim",
  --   -- name = "catppuccin",
  --   priority = 1000,
  --   opts = { flavour = "macchiato" },
  --   lazy = colorscheme ~= "catppuccin",
  --   config = function()
  --     if colorscheme == "catppuccin" then
  --       ColorMyPencils()
  --     end
  --   end,
  -- },
  -- {
  --   "navarasu/onedark.nvim",
  --   -- name = "onedark",
  --   priority = 1000,
  --   opts = { style = "darker" },
  --   lazy = colorscheme ~= "onedark",
  --   config = function()
  --     if colorscheme == "onedark" then
  --       ColorMyPencils()
  --     end
  --   end,
  -- },
  -- {
  --   "scottmckendry/cyberdream.nvim",
  --   -- name = "cyberdream",
  --   priority = 1000,
  --   opts = { transparent = true },
  --   lazy = colorscheme ~= "cyberdream",
  --   config = function()
  --     if colorscheme == "cyberdream" then
  --       ColorMyPencils()
  --     end
  --   end,
  -- },
  -- {
  --   "shaunsingh/nord.nvim",
  --   -- name = "nord",
  --   priority = 1000,
  --   lazy = colorscheme ~= "nord",
  --   config = function()
  --     if colorscheme == "nord" then
  --       ColorMyPencils()
  --     end
  --   end,
  -- },
  -- {
  --   "projekt0n/github-nvim-theme",
  --   -- name = "github-theme",
  --   priority = 1000,
  --   lazy = not vim.startswith(colorscheme, "github_"),
  --   config = function()
  --     if vim.startswith(colorscheme, "github_") then
  --       ColorMyPencils()
  --     end
  --   end,
  -- },
  -- {
  --   "rose-pine/neovim",
  --   name = "rose-pine",
  --   priority = 1000,
  --   lazy = not vim.startswith(colorscheme, "rose-pine"),
  --   opts = {
  --     styles = {
  --       bold = true,
  --       italic = true,
  --       transparency = false,
  --     },
  --   },
  --   config = function()
  --     if vim.startswith(colorscheme, "rose-pine") then
  --       ColorMyPencils()
  --     end
  --   end,
  -- },
  -- {
  --   "rebelot/kanagawa.nvim",
  --   -- name = "kanagawa",
  --   priority = 1000,
  --   opts = {},
  --   lazy = not vim.startswith(colorscheme, "kanagawa"),
  --   config = function()
  --     if vim.startswith(colorscheme, "kanagawa") then
  --       ColorMyPencils()
  --     end
  --   end,
  -- },
  -- {
  --   "Mofiqul/vscode.nvim",
  --   -- name = "vscode-theme",
  --   priority = 1000,
  --   lazy = colorscheme ~= "vscode",
  --   config = function()
  --     if colorscheme == "vscode" then
  --       ColorMyPencils()
  --     end
  --   end,
  -- },
  -- {
  --   "Mofiqul/dracula.nvim",
  --   -- name = "dracula",
  --   priority = 1000,
  --   lazy = not vim.startswith(colorscheme, "dracula"),
  --   config = function()
  --     if vim.startswith(colorscheme, "dracula") then
  --       ColorMyPencils()
  --     end
  --   end,
  -- },

  -- Custom Color command
  -- {
  --   "color",
  --   dir = vim.fn.stdpath("config"), -- dummy plugin
  --   lazy = false,
  --   priority = 999, -- Load after colorschemes
  --   config = function()
  --     vim.api.nvim_create_user_command("Color", function(opts)
  --       if opts.args ~= "" then
  --         -- Set the specified colorscheme
  --         ColorMyPencils(opts.args)
  --       else
  --         -- Cycle to next available colorscheme
  --         local current = vim.g.colors_name or colorscheme
  --         local available = vim.fn.getcompletion("", "color")
  --
  --         if #available == 0 then
  --           vim.notify("No colorschemes available", vim.log.levels.WARN)
  --           return
  --         end
  --
  --         local current_idx = 1
  --         for i, color in ipairs(available) do
  --           if color == current then
  --             current_idx = i
  --             break
  --           end
  --         end
  --
  --         local next_idx = (current_idx % #available) + 1
  --         ColorMyPencils(available[next_idx])
  --         vim.notify("Colorscheme: " .. available[next_idx], vim.log.levels.INFO)
  --       end
  --     end, {
  --       nargs = "?",
  --       complete = "color",
  --       desc = "Cycle or set colorscheme with transparency",
  --     })
  --   end,
  -- },
}
