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
}
