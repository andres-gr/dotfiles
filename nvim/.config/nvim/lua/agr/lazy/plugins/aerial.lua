local A = {
  'stevearc/aerial.nvim',
  cmd = {
    'AerialInfo',
    'AerialOpen',
    'AerialToggle',
  },
}

A.config = function ()
  local aerial = require 'aerial'

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
      local keymap = require 'agr.core.utils'.keymap
      local map = keymap.map
      local desc_opts = function (desc)
        return keymap:desc_opts(desc, bufnr)
      end

      -- Jump forwards/backwards with '[y' and ']y'
      map('n', '[y', '<CMD>AerialPrev<CR>', desc_opts('Previous Aerial'))
      map('n', ']y', '<CMD>AerialNext<CR>', desc_opts('Next Aerial'))
      -- Jump up the tree with '[Y' or ']Y'
      map('n', '[Y', '<CMD>AerialPrevUp<CR>', desc_opts('Previous and Up in Aerial'))
      map('n', ']Y', '<CMD>AerialNextUp<CR>', desc_opts('Next and Up in Aerial'))
    end,
    show_guides = true,
  }
end

return A
