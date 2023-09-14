local F = {
  'folke/flash.nvim',
  event = 'BufReadPre',
}

local mode = function (str)
  return '\\<' .. str
end

F.config = function ()
  local flash = require 'flash'

  local keymap = require 'agr.core.utils'.keymap
  local map = keymap.map
  local desc_opts = function (desc)
    return keymap:desc_opts(desc)
  end

  map('n', '<leader>s', function ()
    flash.jump {
      search = {
        forward = true,
        mode = mode,
        multi_window = false,
        wrap = false,
      },
    }
  end, desc_opts('Flash forward'))

  map('n', '<leader>S', function ()
    flash.jump {
      search = {
        forward = false,
        mode = mode,
        multi_window = false,
        wrap = false,
      },
    }
  end, desc_opts('Flash backward'))
end

return F
