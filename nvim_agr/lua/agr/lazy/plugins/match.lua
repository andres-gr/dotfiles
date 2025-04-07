local M = {
  'andymass/vim-matchup',
}

M.config = function ()
  vim.g.matchup_matchparen_offscreen = { method = 'popup' }
end

return M
