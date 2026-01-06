return {
  -- search/replace in multiple files
  "MagicDuck/grug-far.nvim",
  opts = { headerMaxWidth = 80 },
  cmd = { "GrugFar", "GrugFarWithin" },
  keys = {
    {
      "<leader>sr",
      function()
        local grug = require("grug-far")
        local ext = vim.bo.buftype == "" and vim.fn.expand("%:e")
        -- Temporarily set splitright to open on the right
        local old_splitright = vim.opt.splitright:get()
        vim.opt.splitright = true
        grug.open({
          transient = true,
          prefills = {
            filesFilter = ext and ext ~= "" and "*." .. ext or nil,
          },
        })
        vim.opt.splitright = old_splitright
      end,
      mode = { "n", "x" },
      desc = "Search and Replace",
    },
  },
}
