local M = {
  'andymass/vim-matchup',
}

M.config = function ()
  vim.g.matchup_matchparen_offscreen = { method = 'popup' }

  -- -- Disable treesitter specifically for Go to stop the E5108 error
  -- vim.api.nvim_create_autocmd("FileType", {
  --   pattern = "go",
  --   callback = function()
  --     vim.b.matchup_matchparen_enabled = 0 -- Disables the TS-based matching for this buffer
  --   end,
  -- })
end

return M
