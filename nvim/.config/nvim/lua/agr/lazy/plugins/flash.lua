local F = {
  'folke/flash.nvim',
  event = 'BufReadPre',
}

F.config = function ()
  local mode = 'exact'

  local flash = require 'flash'

  flash.setup {
    modes = {
      char = {
        enabled = false,
      },
    },
  }

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

  map({ 'n', 'o', 'x' }, '<C-S>', function ()
    flash.treesitter {
      actions = {
        ['<C-S>'] = 'next',
        ['<BS>'] = 'prev',
      },
      label = {
        after = false,
        before = false,
      },
    }
  end, desc_opts('Treesitter flash incremental selection'))
end

return F
