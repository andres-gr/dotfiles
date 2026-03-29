local M = {
  'OXY2DEV/markview.nvim',
  lazy = false,
}

M.config = function ()
  local markview = require 'markview'

  markview.setup {
    preview = {
      enable = false,
      icon_provider = 'devicons',
    },
  }

  local utils = require 'agr.core.utils'
  local keymap = utils.keymap
  local map = keymap.map
  local desc_opts = function (desc)
    return keymap:desc_opts(desc)
  end

  map('n', '<leader>m', '<CMD>Markview<CR>', desc_opts('Toggle markdown preview'))
end

return M
