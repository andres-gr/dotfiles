local Z = {
  'folke/zen-mode.nvim',
  cmd = 'ZenMode',
}

Z.config = function ()
  local zen = require 'zen-mode'

  zen.setup {
    plugins = {
      gitsigns = { enabled = true },
    },
    window = {
      backdrop = 1,
      width = 0.55,
    },
  }
end

return Z
