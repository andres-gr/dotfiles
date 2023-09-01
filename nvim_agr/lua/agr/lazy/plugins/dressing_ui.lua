local D = {
  'stevearc/dressing.nvim',
  event = 'BufWinEnter',
}

D.config = function ()
  local dressing = require 'dressing'

  dressing.setup {
    input = {
      default_prompt = '➤ ',
      win_options = { winhighlight = 'Normal:Normal,NormalNC:Normal' },
    },
    select = {
      backend = {
        'builtin',
        'telescope',
      },
      builtin = {
        win_options = { winhighlight = 'Normal:Normal,NormalNC:Normal' },
      },
    },
  }
end

return D
