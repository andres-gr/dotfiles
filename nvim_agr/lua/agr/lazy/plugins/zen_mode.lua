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
      height = 0.8,
      width = 0.65,
    },
  }
end

return Z
