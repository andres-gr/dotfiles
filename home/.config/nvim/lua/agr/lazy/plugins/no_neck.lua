local N = {
  'shortcuts/no-neck-pain.nvim',
  cmd = 'NoNeckPain',
  event = 'BufReadPost',
  version = '*',
}

N.config = function ()
  local no_neck_pain = require 'no-neck-pain'
  local utils = require 'agr.core.utils'

  no_neck_pain.setup {
    buffers = {
      setNames = true,
    },
    integration = {
      NeoTree = {
        enabled = true,
        position = 'left',
      },
    },
    width = 150,
  }

  local keymap = utils.keymap
  local map = keymap.map
  local desc_opts = function (desc)
    return keymap:desc_opts(desc)
  end

  map('n', '\\n', '<CMD>Neotree close<CR><CMD>NoNeckPain<CR>', desc_opts('Toggle No Neck Pain'))
end

return N
