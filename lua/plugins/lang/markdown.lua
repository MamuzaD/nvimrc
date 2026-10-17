return {
  {
    "MeanderingProgrammer/render-markdown.nvim",
    ft = { "markdown" },
    cmd = "RenderMarkdown",
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "nvim-mini/mini.icons",
    },
    opts = {
      code = {
        sign = false,
        width = "block",
        right_pad = 1,
      },
      heading = {
        sign = false,
        icons = {},
      },
      checkbox = {
        enabled = false,
      },
    },
    config = function(_, opts)
      local markdown = require("render-markdown")
      markdown.setup(opts)
      require("snacks").toggle({
        name = "Render Markdown",
        get = markdown.get,
        set = markdown.set,
      }):map("<leader>um")
    end,
  },
}
