local G = {
  'akinsho/git-conflict.nvim',
  event = {
    'BufNewFile',
    'BufReadPre',
  },
}

G.config = function ()
  local conflict = require('git-conflict')

  conflict.setup {
    default_mappings = false, -- disable buffer local mapping created by this plugin
    default_commands = true, -- disable commands created by this plugin
    disable_diagnostics = false, -- This will disable the diagnostics in a buffer whilst it is conflicted
    highlights = { -- They must have background color, otherwise the default color will be used
      incoming = 'DiffText',
      current = 'DiffAdd',
    }
  }

  local keymap = require 'agr.core.utils'.keymap
  local map = keymap.map
  local desc_opts = function (desc)
    return keymap:desc_opts(desc)
  end

  map('n', '<leader>gco', '<Plug>(git-conflict-ours)', desc_opts('Git conflict choose ours'))
  map('n', '<leader>gct', '<Plug>(git-conflict-theirs)', desc_opts('Git conflict choose theirs'))
  map('n', '<leader>gcb', '<Plug>(git-conflict-both)', desc_opts('Git conflict choose both'))
  map('n', '<leader>gcn', '<Plug>(git-conflict-none)', desc_opts('Git conflict choose none'))
  map('n', '[x', '<Plug>(git-conflict-prev-conflict)', desc_opts('Git prev conflict'))
  map('n', ']x', '<Plug>(git-conflict-next-conflict)', desc_opts('Git next conflict'))
end

return G
