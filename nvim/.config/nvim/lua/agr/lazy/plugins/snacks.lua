local S = {
  'folke/snacks.nvim',
  lazy = false,
  priority = 1000,
}

S.opts = {
  lazygit = {
    configure = true,
    theme = {
      selectedLineBgColor = { bg = 'NeoTreeCursorLine' }
    }
  },
}

S.keys = {
  ---@diagnostic disable-next-line: undefined-global
  { '<leader>lg', function() Snacks.lazygit() end, desc = 'LazyGit' },
}

return S
