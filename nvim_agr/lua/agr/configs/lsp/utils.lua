local U = {}

local sendEsc = function ()
  local esc = vim.api.nvim_replace_termcodes(':nohl<CR>:echon \'\'<CR>', true, false, true)
  vim.api.nvim_feedkeys(esc, 'n', false)
end

U.saga_cursor_diagnostics = function ()
  vim.cmd 'Lspsaga show_cursor_diagnostics'
  vim.defer_fn(sendEsc, 50)
end

U.saga_line_diagnostics = function ()
  vim.cmd 'Lspsaga show_line_diagnostics'
  vim.defer_fn(sendEsc, 50)
end

U.saga_hover_doc = function ()
  vim.cmd 'Lspsaga hover_doc'
  vim.defer_fn(sendEsc, 50)
end

return U

