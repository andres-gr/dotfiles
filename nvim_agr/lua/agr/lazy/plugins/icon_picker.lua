local I = {
  'ziontee113/icon-picker.nvim',
  dependencies = {
    'stevearc/dressing.nvim',
  },
  event = 'BufEnter',
  lazy = true,
}

I.config = function ()
  local icon = require('icon-picker')

  icon.setup {
    disable_legacy_commands = true,
  }
end

return I
