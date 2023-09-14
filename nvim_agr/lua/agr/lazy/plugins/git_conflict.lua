local G = {
  'akinsho/git-conflict.nvim',
  event = {
    'BufNewFile',
    'BufReadPre',
  },
  version = '*',
}

G.config = function ()
  local conflict = require('git-conflict')

  conflict.setup {
    default_mappings = false, -- disable buffer local mapping created by this plugin
    default_commands = true, -- disable commands created by this plugin
    disable_diagnostics = false, -- This will disable the diagnostics in a buffer whilst it is conflicted
    highlights = { -- They must have background color, otherwise the default color will be used
      -- current = 'DiffText',
      -- incoming = 'DiffAdd',
      current = 'GitConflictDiffCurrent',
      incoming = 'GitConflictDiffIncoming',
    }
  }

  local keymap = require 'agr.core.utils'.keymap
  local map = keymap.map
  local desc_opts = function (desc)
    return keymap:desc_opts(desc)
  end

  map('n', '<leader>gco', '<CMD>GitConflictChooseOurs<CR>', desc_opts('Git conflict choose ours'))
  map('n', '<leader>gct', '<CMD>GitConflictChooseTheirs<CR>', desc_opts('Git conflict choose theirs'))
  map('n', '<leader>gcb', '<CMD>GitConflictChooseBoth<CR>', desc_opts('Git conflict choose both'))
  map('n', '<leader>gcn', '<CMD>GitConflictChooseNone<CR>', desc_opts('Git conflict choose none'))
  map('n', '[x', '<CMD>GitConflictNextConflict<CR>', desc_opts('Git prev conflict'))
  map('n', ']x', '<CMD>GitConflictPrevConflict<CR>', desc_opts('Git next conflict'))
  map('n', '<leader>gcq', '<CMD>GitConflictListQf<CR>', desc_opts('Git conflict to qflist'))
end

return G
