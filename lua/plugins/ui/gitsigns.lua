return {
  "lewis6991/gitsigns.nvim",
  event = "LazyFile",
  keys = {
    {
      "<leader>gb",
      function()
        -- toggle the dedicated blame view
        for _, win in ipairs(vim.api.nvim_list_wins()) do
          local buf = vim.api.nvim_win_get_buf(win)
          local name = vim.api.nvim_buf_get_name(buf)
          local ft = vim.bo[buf].filetype
          if name:find("gitsigns://blame", 1, true) or (ft:find("gitsigns", 1, true) and ft:find("blame", 1, true)) then
            pcall(vim.api.nvim_win_close, win, true)
            return
          end
        end
        require("gitsigns").blame()
      end,
      desc = "Blame Buffer",
    },
  },
  opts = {
    signs = {
      add = { text = "▎" },
      change = { text = "▎" },
      delete = { text = "" },
      topdelete = { text = "" },
      changedelete = { text = "▎" },
      untracked = { text = "▎" },
    },
    signs_staged = {
      add = { text = "▎" },
      change = { text = "▎" },
      delete = { text = "" },
      topdelete = { text = "" },
      changedelete = { text = "▎" },
    },
    current_line_blame = true,
  },
}
