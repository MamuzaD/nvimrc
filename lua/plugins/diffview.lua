local function toggle_diffview(toggle_files)
  local view = require("diffview.lib").get_current_view()
  if view then
    vim.cmd("DiffviewClose")
  else
    vim.cmd("DiffviewOpen")
    if toggle_files then
      vim.cmd("DiffviewToggleFiles")
    end
  end
end

return {
  "sindrets/diffview.nvim",
  lazy = true,
  keys = {
    -- stylua: ignore
    { "<leader>gd", function() toggle_diffview(true) end, desc = "Diffview (buffer)" },
    -- stylua: ignore
    { "<leader>gD", function() toggle_diffview(false) end, desc = "Diffview" },
  },
}
