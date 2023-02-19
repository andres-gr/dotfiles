local G = {
  'akinsho/git-conflict.nvim',
  event = 'BufReadPre',
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
end

return G
