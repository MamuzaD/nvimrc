-- Shared helper for the oxc toolchain (oxfmt + oxlint).
--
-- Toggle with `vim.g.use_oxc`:
--   * true  -> oxfmt formats + oxlint lints JS/TS
--   * false -> prettier formats (+ eslint, if enabled) instead
-- Default is set in `daniel.options`.
local M = {}

-- Filetypes oxfmt can format. Everything else still goes through prettier.
M.fmt_filetypes = {
  "javascript",
  "javascriptreact",
  "typescript",
  "typescriptreact",
  "json",
  "jsonc",
}

-- Filetypes oxlint can lint (JS/TS only, no json).
M.lint_filetypes = {
  "javascript",
  "javascriptreact",
  "typescript",
  "typescriptreact",
}

-- oxfmt config files. When `vim.g.oxc_needs_config` is true, oxfmt only runs
-- if one of these is found upward from the buffer.
-- https://oxc.rs/docs/guide/usage/formatter/config.html
M.config_files = {
  ".oxfmtrc.json",
  ".oxfmtrc.jsonc",
  "oxfmt.config.ts",
}

--- Whether the oxc toolchain is currently active.
function M.enabled()
  return vim.g.use_oxc == true
end

--- True when oxfmt should own formatting for the given filetype.
---@param ft string
function M.handles_fmt(ft)
  return M.enabled() and vim.tbl_contains(M.fmt_filetypes, ft)
end

--- True when an oxfmt config file exists upward from the given path.
---@param filename string
function M.has_config(filename)
  return vim.fs.find(M.config_files, { path = filename, upward = true })[1] ~= nil
end

--- True when oxfmt will actually format this buffer (used to gate both the
--- oxfmt formatter and prettier's back-off, so they stay in sync).
---@param filename string
---@param ft string
function M.formats(filename, ft)
  if not M.handles_fmt(ft) then
    return false
  end
  return vim.g.oxc_needs_config ~= true or M.has_config(filename)
end

return M
