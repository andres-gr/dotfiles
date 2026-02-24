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
      backdrop = 0.9,
      height = 0.95,
      width = 0.7,
    },
  }
end

return Z
