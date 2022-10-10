local aerial_status_ok, aerial = pcall(require, 'aerial')
if not aerial_status_ok then return end

aerial.setup {
  attach_mode = 'global',
  backends = {
    'lsp',
    'markdown',
    'treesitter',
  },
  filter_kind = false,
  guides = {
    mid_item = '├ ',
    last_item = '└ ',
    nested_top = '│ ',
    whitespace = '  ',
  },
  layout = {
    min_width = 28,
  },
  on_attach = function (bufnr)
    -- Jump forwards/backwards with '[y' and ']y'
    vim.keymap.set('n', '[y', '<cmd>AerialPrev<cr>', { buffer = bufnr, desc = 'Previous Aerial' })
    vim.keymap.set('n', ']y', '<cmd>AerialNext<cr>', { buffer = bufnr, desc = 'Next Aerial' })
    -- Jump up the tree with '[Y' or ']Y'
    vim.keymap.set('n', '[Y', '<cmd>AerialPrevUp<cr>', { buffer = bufnr, desc = 'Previous and Up in Aerial' })
    vim.keymap.set('n', ']Y', '<cmd>AerialNextUp<cr>', { buffer = bufnr, desc = 'Next and Up in Aerial' })
  end,
  show_guides = true,
}

