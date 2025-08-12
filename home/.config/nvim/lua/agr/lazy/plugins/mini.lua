local M = {
  'echasnovski/mini.ai',
  event = {
    'BufNewFile',
    'BufReadPost',
  },
  version = '*',
}

M.config = function ()
  require 'mini.ai'.setup()
end

return M
