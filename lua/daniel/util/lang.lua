local M = {}

function M.source_action(only)
  return function()
    vim.lsp.buf.code_action({
      apply = true,
      context = { only = { only } },
    })
  end
end

function M.execute_command(command, arguments, open)
  local params = { command = command, arguments = arguments }
  vim.lsp.buf_request(0, "workspace/executeCommand", params, function(err, result)
    if err then
      vim.notify(err.message or tostring(err), vim.log.levels.ERROR)
      return
    end
    if not open or result == nil then
      return
    end

    -- workspace edit
    if type(result) == "table" and (result.documentChanges or result.changes) then
      pcall(vim.lsp.util.apply_workspace_edit, result, "utf-16")
      return
    end

    -- location or location[]
    local loc = result
    if type(loc) == "table" and vim.islist(loc) then
      loc = loc[1]
    end
    if type(loc) ~= "table" then
      return
    end

    -- LSP LocationLink -> Location
    if loc.targetUri and loc.targetSelectionRange then
      loc = { uri = loc.targetUri, range = loc.targetSelectionRange }
    end

    if loc.uri and loc.range then
      pcall(vim.lsp.util.show_document, loc, { focus = true })
    end
  end)
end

return M
