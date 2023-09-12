local N = {
  'rcarriga/nvim-notify',
  event = 'BufWinEnter',
}

N.config = function ()
  local notify = require 'notify'

  notify.setup {
    background_colour = '#000000',
    fps = 120,
    max_height = 50,
    max_width = 100,
    stages = 'fade_in_slide_out',
    timeout = 1500,
  }

  vim.notify = notify
end

return N
