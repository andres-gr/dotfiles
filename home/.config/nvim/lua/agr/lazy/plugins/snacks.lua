local S = {
  'folke/snacks.nvim',
  lazy = false,
  priority = 1000,
}

S.opts = {
  lazygit = {},
}

S.keys = {
  { '<leader>lg', function () Snacks.lazygit() end, desc = 'LazyGit' },
}

return S
