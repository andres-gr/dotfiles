local S = {
  'sQVe/sort.nvim',
  event = {
    'BufNewFile',
    'BufReadPost',
  },
}

S.config = function ()
  local sort = require 'sort'

  sort.setup()

  local keymap = require 'agr.core.utils'.keymap
  local map = keymap.map
  local desc_opts = function (desc)
    return keymap:desc_opts(desc)
  end

  map('v', '<leader>s', '<ESC><CMD>Sort<CR>', desc_opts('Sort visual line'))
end

return S
