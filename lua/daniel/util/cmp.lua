--- old ai stuff
---@class daniel.util.cmp
local M = {}

M.CREATE_UNDO = vim.api.nvim_replace_termcodes("<c-G>u", true, true, true)

---Create an undo breakpoint to isolate the next edit
function M.create_undo()
  if vim.api.nvim_get_mode().mode == "i" then
    vim.api.nvim_feedkeys(M.CREATE_UNDO, "n", false)
  end
end

---@alias daniel.util.cmp.Action fun():boolean?
---@type table<string, daniel.util.cmp.Action>
M.actions = {
  -- Native Snippets
  snippet_forward = function()
    if vim.snippet.active({ direction = 1 }) then
      vim.schedule(function()
        vim.snippet.jump(1)
      end)
      return true
    end
  end,
  snippet_stop = function()
    if vim.snippet then
      vim.snippet.stop()
    end
  end,
  -- AI completion accept
  ai_accept = function()
    if not vim.g.ai_cmp then
      return false
    end
    local blink = require("blink.cmp")
    -- First try Supermaven native suggestion (when ai_cmp = false)
    local has_supermaven, suggestion = pcall(require, "supermaven-nvim.completion_preview")
    if has_supermaven and suggestion.has_suggestion() then
      M.create_undo()
      vim.schedule(function()
        suggestion.on_accept_suggestion()
      end)
      return true
    end
    -- Otherwise select and accept the current completion (like super-tab)
    if blink.is_menu_visible() or blink.is_ghost_text_visible() then
      M.create_undo()
      blink.select_and_accept()
      return true
    end
    return false
  end,
}

---@param actions string[]
---@param fallback? string|fun()
function M.map(actions, fallback)
  return function()
    for _, name in ipairs(actions) do
      if M.actions[name] then
        local ret = M.actions[name]()
        if ret then
          return true
        end
      end
    end
    return type(fallback) == "function" and fallback() or fallback
  end
end

---@alias Placeholder {n:number, text:string}

---@param snippet string
---@param fn fun(placeholder:Placeholder):string
---@return string
function M.snippet_replace(snippet, fn)
  return snippet:gsub("%$%b{}", function(m)
    local n, name = m:match("^%${(%d+):(.+)}$")
    return n and fn({ n = n, text = name }) or m
  end) or snippet
end

-- This function resolves nested placeholders in a snippet.
---@param snippet string
---@return string
function M.snippet_preview(snippet)
  local ok, parsed = pcall(function()
    return vim.lsp._snippet_grammar.parse(snippet)
  end)
  return ok and tostring(parsed)
    or M.snippet_replace(snippet, function(placeholder)
      return M.snippet_preview(placeholder.text)
    end):gsub("%$0", "")
end

-- This function replaces nested placeholders in a snippet with LSP placeholders.
function M.snippet_fix(snippet)
  local texts = {} ---@type table<number, string>
  return M.snippet_replace(snippet, function(placeholder)
    texts[placeholder.n] = texts[placeholder.n] or M.snippet_preview(placeholder.text)
    return "${" .. placeholder.n .. ":" .. texts[placeholder.n] .. "}"
  end)
end

function M.expand(snippet)
  -- Native sessions don't support nested snippet sessions.
  -- Always use the top-level session.
  -- Otherwise, when on the first placeholder and selecting a new completion,
  -- the nested session will be used instead of the top-level session.
  -- See: https://github.com/LazyVim/LazyVim/issues/3199
  local session = vim.snippet.active() and vim.snippet._session or nil

  local ok, err = pcall(vim.snippet.expand, snippet)
  if not ok then
    local fixed = M.snippet_fix(snippet)
    ok = pcall(vim.snippet.expand, fixed)

    local msg = ok and "Failed to parse snippet,\nbut was able to fix it automatically."
      or ("Failed to parse snippet.\n" .. err)

    vim.notify(
      ([[%s
```%s
%s
```]]):format(msg, vim.bo.filetype, snippet),
      { title = "vim.snippet", level = ok and vim.log.levels.WARN or vim.log.levels.ERROR }
    )
  end

  -- Restore top-level session when needed
  if session then
    vim.snippet._session = session
  end
end

return M
